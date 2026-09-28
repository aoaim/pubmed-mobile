# AGENTS.md — PubMed Mobile 工程说明

> 本文件供 AI 编码助手（GitHub Copilot、Claude Code、Cursor、Codex 等）与人类维护者阅读。
> 目标：保证任何工具接手本项目时，都能遵循同一套工程约定，不破坏既有架构与行为。
> 用户使用说明见 `README.md`；架构、构建、数据流、API 集成与发布细节见 `DEVELOPMENT.md`。

---

## 1. 项目概览

- **是什么**：非官方 PubMed 文献检索 Android 客户端（Flutter）。支持关键词搜索、文献详情、PMC 免费全文阅读、收藏、离线缓存、中英互译、期刊分区查询。
- **技术栈**：Flutter (Dart 3.13+) · Material 3 + Dynamic Color · flutter_riverpod · dio · freezed · drift (SQLite) · go_router · flutter_inappwebview · shared_preferences + flutter_secure_storage · aptabase_flutter（分析）
- **包名**：`pubmed_mobile`（Dart 包标识，勿改）
- **Android applicationId**：`dev.aoaim.pubmed_mobile`（`android/app/build.gradle.kts`）
- **桌面显示名**：`PubMed`（`AndroidManifest.xml` 的 `android:label`）
- **版本**：`pubspec.yaml` 的 `version`（当前 `0.2.0+7`）是**唯一版本来源**——Android 构建（versionName/versionCode）与设置页「关于 → 检查更新」显示均从它派生（设置页用 `package_info_plus` 运行时读取，**不要写死版本文案**）。
- **更新日志**：`CHANGELOG.md`（格式见 §11，App 内「检查更新」功能依赖它）。
- **当前平台**：Android（compileSdk 36, minSdk 29）。增加其他平台时，应同时补齐构建、数据存储、凭据、WebView 和测试配置。

## 2. 环境与命令

```bash
# 本机 Flutter SDK 路径（非 PATH 内，必须用全路径）
FLUTTER=/Users/miao/.codex/.chatgpt-projects/g-p-6ab8c30ea14481918a3f51073aee5e31/flutter-sdk/bin/flutter

# 拉依赖
$FLUTTER pub get

# 代码生成（改了 @freezed 模型或 Drift 表后必须执行）
dart run build_runner build

# 静态检查（每次改动后必须跑，要求 0 issue）
$FLUTTER analyze

# 测试（要求全部通过）
$FLUTTER test

# 运行
$FLUTTER run

# 发布构建（arm64 瘦身包）
$FLUTTER build apk --release --target-platform=android-arm64
```

**每次改动后的最低验证标准**：`flutter analyze` 0 issue + `flutter test` 全绿。

## 3. 目录结构与架构约定

```
lib/
├── main.dart            # 入口：初始化 Analytics → SharedPreferences → SettingsRepository → ProviderScope
├── core/                # 全局基础设施（不挂业务）
│   ├── analytics/       # Aptabase 封装（见 §6）
│   ├── constants/       # app_constants.dart：NCBI URL、限流、缓存天数等常量
│   ├── database/        # Drift 数据库（app_database.dart + 生成的 .g.dart）
│   ├── error/           # 错误类型（当前为空，新增错误类型放这里）
│   ├── l10n/            # 手写国际化（见 §5）
│   ├── network/         # dio_client.dart + rate_limiter.dart
│   ├── router/          # go_router 路由表
│   ├── theme/           # Material 3 主题
│   └── widgets/         # app_shell.dart 底部导航外壳
└── features/            # 业务模块，每个模块内部分三层：
    ├── <feature>/
    │   ├── data/        # datasources/（API 调用）、repositories/（缓存桥接）、services/（第三方服务）
    │   ├── domain/      # entities/（freezed 不可变模型）、错误类型
    │   └── presentation/
    │       ├── providers/   # Riverpod 状态
    │       ├── screens/     # 页面（ConsumerStatefulWidget / ConsumerWidget）
    │       └── widgets/     # 页面内组件
```

**当前架构约定**（新增功能可按实际规模调整目录，调整时说明原因并更新本文档）：

- 业务模块优先放在 `features/<name>/`；`core/` 放可复用的基础设施。简单功能不必为凑齐三层创建空目录。
- 领域模型不依赖 UI 或数据实现；数据层依赖领域模型。现有页面仍有直接访问仓库或数据库的代码，改动时可逐步收敛。
- 跨页面状态沿用 Riverpod；页面内临时交互可用 `setState`。若未来更换方案，先评估迁移范围。
- 现有文章模型沿用 Freezed，持久化沿用 Drift；新模型按复杂度选型，不强制全部套用同一模板。

## 4. 核心基础设施

### 4.1 数据库（Drift，`lib/core/database/app_database.dart`）

四张表：

| 表                 | 用途                    | 主键      | 过期策略                       |
| ------------------ | ----------------------- | --------- | ------------------------------ |
| `CachedArticles`   | 搜索结果 + 文献详情缓存 | `pmid`    | 搜索 7 天 / 详情 30 天自动清理 |
| `Favorites`        | 收藏                    | `pmid`    | 永久                           |
| `SearchHistory`    | 搜索历史                | 自增 `id` | 7 天清理，最多 50 条           |
| `PmcFullTextCache` | PMC 全文 HTML           | `pmcid`   | 不自动过期，超容量淘汰最旧     |

- 改表结构必须：① 更新 `schemaVersion` ② 在 `migration` 中补升级逻辑 ③ 重跑 build_runner ④ 验证旧数据库升级及新安装建库。
- 数据库文件在 `getApplicationDocumentsDirectory()/pubmed_mobile.sqlite`，用 `NativeDatabase.createInBackground()` 后台 isolate 运行。
- 搜索页缓存按 PMID 批量读取，批量写入放在同一事务内；保留 PubMed 原始结果顺序及已有详情、译文。PMC 缓存超容量时按最旧记录淘汰，仅在超限时读取各条大小，不把全文 HTML 载入 Dart 内存。
- 写入用 `FavoritesCompanion(...)` + `Value(...)` 包装可空字段。
- 升级安装必须保留同一 `applicationId` 与发布签名，并将 `pubspec.yaml` 的 `+build`（Android versionCode）递增。禁止为修复迁移问题删除用户数据库、SharedPreferences 或安全存储；新增字段需验证旧版数据库升级。`allowBackup=false` 仅影响卸载/换机后的系统恢复，不影响原地升级。

### 4.2 网络层（`lib/core/network/`）

- `dio_client.dart`：Dio 实例 + 三个拦截器（顺序固定）：
  1. `RateLimitInterceptor` — 令牌桶限流（无 API Key 3 req/s，有 Key 10 req/s）
  2. `RetryOn429Interceptor` — 429 时按 `Retry-After` 等待重试，最多 3 次
  3. `LogInterceptor` — 仅 debug 模式
- API Key 通过 `api_key` query 参数注入；Key 变更后 Dio 实例经 Riverpod 自动重建。
- NCBI E-utilities 四个调用封装在 `features/search/data/datasources/pubmed_api_datasource.dart`：ESearch / ESummary（JSON）/ EFetch（**XML 解析**）/ ESpell。
- 常量（`core/constants/app_constants.dart`）：`ncbiBaseUrl`、`rateLimitWithoutKey=3`、`rateLimitWithKey=10`、`defaultPageSize=20`、`searchCacheDays=7`、`detailCacheDays=30`、`maxHistoryItems=50`。

### 4.3 路由（`lib/core/router/app_router.dart`）

| 路径             | 页面                | 说明                                        |
| ---------------- | ------------------- | ------------------------------------------- |
| `/splash`        | SplashScreen        | 启动页，`context.go(AppRoutes.search)` 跳转 |
| `/search`        | SearchScreen        | 默认首页（ShellRoute 内）                   |
| `/favorites`     | FavoritesScreen     | 收藏（ShellRoute 内）                       |
| `/settings`      | SettingsScreen      | 设置（ShellRoute 内）                       |
| `/article/:pmid` | ArticleDetailScreen | 全屏，`pmid` 为 int                         |
| `/reader/:pmcid` | ReaderScreen        | PMC 阅读器，全屏                            |

- 路径常量统一走 `AppRoutes` 类，**不要**手写字符串路径。
- 页面跳转用 `context.push(...)` / `context.go(...)`（go_router 扩展）。
- ShellRoute 内页面用 `NoTransitionPage`；`SearchScreen` 有 `globalKey`（`SearchScreen.globalKey`），勿删。

### 4.4 主题（`lib/core/theme/app_theme.dart`）

- Material 3，seed color `#1565C0`（PubMed 蓝），`light()` / `dark()` 工厂方法。
- 支持 Dynamic Color（Android 12+ 壁纸取色），通过 `useDynamicColorProvider` 开关。
- 字体：本地打包的 Inter（`assets/fonts/`），不依赖运行时下载。

### 4.5 设置与凭据（`lib/features/settings/data/settings_repository.dart`）

- 普通设置 → `SharedPreferences`；**API Key 类凭据 → `FlutterSecureStorage`**（含旧数据自动迁移逻辑，勿破坏）。
- 凭据 Key：NCBI `ncbi_api_key`、DeepL `deepl_api_key`、OpenAI 兼容 `openai_api_key`、easyScholar `easy_scholar_key`。
- OpenAI 兼容通道预设为 DeepSeek 官方 `https://api.deepseek.com` / `deepseek-flash`；默认翻译通道仍为 DeepL。当前修正版首次启动会重置一次 Base URL 与模型但保留 Key，之后必须保留用户手动保存的配置。保存 Key 或成功刷新模型列表时，必须同步保存当前 Base URL、Key 和模型，保证验证与实际翻译使用同一配置。
- 设置类 Provider（都在此文件）：`settingsRepositoryProvider`、`credentialsRevisionProvider`、`translationChannelProvider`、`themeModeProvider`、`localeProvider`、`useDynamicColorProvider`、`pageSizeProvider`、`simplifyPmcReaderProvider`。
- easyScholar 指标选择存于 SharedPreferences；字段名以官方 `officialRank.all` 文档为准。只显示接口返回且用户勾选的指标。中科院分区数据必须附 2026 年起停更说明，不能推测接口未提供的年份。

## 5. 国际化（`lib/core/l10n/app_localizations.dart`）

- **手写方案**，无 arb 文件、无代码生成。支持 `zh-CN` + `en-GB`，约 80+ 条。
- 所有 UI 文案必须通过 `AppLocalizations.of(context)` 获取，**禁止硬编码用户可见字符串**（个别临时文案例外，但需中英双语）。
- 新增文案：在 `app_localizations.dart` 加 getter，同时提供中英两个分支（`_isZh ? '中文' : 'English'`）。
- 部分页面（如详情页按钮）用 `Localizations.localeOf(context).languageCode == 'zh'` 做内联双语判断，保持该风格即可。

## 6. 分析埋点（Aptabase）

- App Key：`A-EU-0620997581`，在 `main.dart` 中 `Analytics.init(...)` 初始化。
- **必须**通过 `lib/core/analytics/analytics.dart` 的封装调用：
  - `Analytics.track(AnalyticsEvents.xxx, {...})` — 事件名常量在 `AnalyticsEvents` 中定义
  - **禁止**直接调用 `Aptabase.instance.trackEvent(...)`（封装层负责测试环境静默跳过）
- 属性只允许 string / number；不得上报 API Key 等凭据。**当前成功搜索事件会发送完整搜索词**，见 README「使用数据与统计」。更改采集范围、服务商、区域或关闭方式时，必须同步更新 README 和用户可见说明；新增字段先核对是否包含敏感信息。
- 新增用户行为埋点时：先在 `AnalyticsEvents` 加常量，再在对应 handler 调用 `Analytics.track`（fire-and-forget，不 await）。
- 现有事件：`app_started`、`search_performed`、`article_opened`、`favorite_added/removed`、`translation_requested/completed/failed`、`reader_opened`、`external_link_opened`、`article_shared`、`theme_changed`、`locale_changed`、`page_size_changed`、`simplify_reader_changed`、`cache_cleared`。

## 7. 关键业务规则（改动前必读）

### 7.1 搜索（`features/search/`）

- 核心状态在 `SearchNotifier`（`search_provider.dart`），所有搜索入口（输入框提交、历史点击、拼写建议、重试）都汇聚到 `search()`。
- **Stale-While-Revalidate 模式**：先查内存缓存 → 再查 7 天 SQLite 缓存 → 无缓存显示骨架屏 → 后台总是拉取网络刷新。不要改成"先网络后缓存"。
- 分页：`loadMore()` 追加下一页；排序：`setSort()`（relevance / date）。
- 搜索不附加 PMC 全文筛选条件；结果卡片仍可根据 PMCID 显示 PMC 标识。旧版 `pmc_only` 历史记录继续保存在数据库中，重放时按普通搜索执行；普通搜索缓存只读取 `pmc_only = false` 的记录。
- 搜索成功后在 `search()` 内上报 `search_performed`（含 query、sort、resultCount）。

### 7.2 文献详情（`features/article_detail/`）

- `_loadData()`：先读缓存立即展示（`_isOffline=true`），再后台 `forceRefresh` 拉新（`_isRefreshing`）。缓存命中时恢复已保存的翻译结果。
- 翻译：`_translateArticle()` 走 `TranslationService`（DeepL / OpenAI 兼容，通道由设置决定）。实际失败转换为 `TranslationFailure`（`domain/translation_failure.dart`，含 kind/provider/stage 枚举），UI 用 `_showTranslationError` 展示分类错误与建议；主动取消的 Dio 请求由阅读页安静处理。
- 标题译文完成后立即显示，并单独写入 `CachedArticles`；摘要随后独立显示、写入。部分成功的缓存需允许下次只重试缺失字段。
- PubMed EFetch 的作者单位存入 `CachedArticles.affiliations`，详情页按原文展示；翻译仅处理标题和摘要。
- 收藏切换在 `_FavoriteButton`（`db.addFavorite/removeFavorite` + `ref.invalidate(isFavoriteProvider(pmid))`）。
- 期刊指标：`easyScholarService` 解析官方文档中的 `officialRank.all`；`JournalMetric` 映射 API 字段，用户选择由 `journalMetricsProvider` 持久化。仅显示有返回值且被选择的指标，中科院数据附 2026 年起停更说明。

### 7.3 PMC 阅读器（`features/reader/`）

- 流程：`_checkCache()` 查 `PmcFullTextCache` → 无缓存时**先用 Dio 下载 HTML 并校验**（`PmcPage.isReadableArticle`，拒绝浏览器检查页/无关长页）→ 以 `initialData` 喂给 InAppWebView（不要直接 loadUrl，避免 WebView 渲染崩溃白屏）。
- 手动刷新（↺）：删除该 pmcid 的 DB 缓存后重新联网。
- 简化模式（`simplifyPmcReaderProvider`）影响 TOC 按钮与页面处理，改动时注意保持两种模式行为一致。
- 阅读页译文通过悬浮按钮手动开启。滚动事件立即取消当前 Dio 请求并递增修订号；停留 650ms 后只枚举当前可见正文段落，逐段翻译并在原段落位置显示。关闭时恢复原始 HTML。结果写 DOM 前必须再检查修订号与可见性；翻译缓存只在当前阅读页内存中，原始全文缓存在注入译文之前保存。

### 7.4 收藏（`features/favorites/`）

- 列表用 `favoritesStreamProvider`（Drift Stream）响应式更新；滑删走 `db.removeFavorite`。

### 7.5 检查更新（`features/updates/`）

- 启动自动检查在 `AppShell.initState`（静默失败，不打扰用户）；设置页「关于 → 检查更新」为手动检查（失败必须提示原因）。
- 获取当前版本用 `package_info_plus`；changelog 从 `UpdateCheckService.changelogUrls` 拉取（**只使用 raw.githubusercontent.com**——jsdelivr 镜像有最长 24h 缓存延迟且需手动 purge，会导致发版后更新提示延迟，故弃用）。
- 版本比较用 `compareVersions`（语义化版本，忽略 `+build`）；「本次忽略此提示」把版本号存 `SharedPreferences`（key `ignored_update_version`），同版本不再自动提示。
- 弹窗统一走 `features/updates/presentation/widgets/update_dialog.dart` 的三个函数（有更新 / 已最新 / 失败）。
- 「更新」按钮跳转 GitHub Releases（`https://github.com/aoaim/pubmed-mobile/releases`）。

## 8. 代码生成与禁止事项

- `*.g.dart`（Drift）、`*.freezed.dart`（freezed）由 build_runner 生成，**禁止手改**；改模型后重跑生成。
- **禁止**修改 `build/`、`.dart_tool/`、`android/` 下的生成产物（`GeneratedPluginRegistrant` 等）。
- 保留现有测试覆盖；改动行为时更新相应测试，不依赖固定的测试文件或用例数量。
- 引入新基础库前检查现有 Riverpod、dio、Drift 能否满足需求，并记录迁移理由。
- 不要用 `print()` 调试，用 `debugPrint` 或日志框架。
- 保持 `flutter analyze` 0 issue（`flutter_lints` 规则集）。

## 9. 测试

- `test/widget_test.dart` — App 冒烟测试（引用 `PubMedMobileApp`）。
- `test/pmc_page_test.dart` — PMC HTML 校验逻辑测试。
- `test/translation_failure_test.dart` — 翻译错误分类测试。
- `test/deepseek_defaults_test.dart` — DeepSeek 默认配置、配置持久化与请求地址测试。
- `test/changelog_parser_test.dart` — CHANGELOG 解析与版本比较测试。
- `test/pubmed_search_detail_test.dart` — 搜索原始查询词与作者单位解析测试。
- `test/database_metadata_migration_test.dart` — 搜索条件缓存隔离与旧数据库升级测试。
- `test/journal_ranking_test.dart` — easyScholar 文档字段映射测试。
- 新增逻辑（尤其纯函数：XML 解析、缓存策略、错误分类、changelog 解析）应补对应单元测试。
- 注意：测试不经过 `main()`，因此 Aptabase 不会初始化（封装层已处理）。

## 10. 发布流程

1. 递增 `pubspec.yaml` 的 `version`，并确保 `+build` 严格高于上一个已发布 APK 的 versionCode；保留原发布签名。设置页「检查更新」下的当前版本由 `package_info_plus` 动态读取，**无需手动同步**。
2. **在 `CHANGELOG.md` 顶部新增对应版本条目**（格式见 §11）。
3. 提交并推送 `main`，打 `v` 开头 tag（如 `v0.2.0`）。
4. `.github/workflows/release.yml` 自动构建并发布 APK 到 GitHub Releases；Release 说明复制匹配的 CHANGELOG 条目并附完整日志链接。
5. 发布前检查清单：`flutter pub get && dart run build_runner build && flutter analyze && flutter test && flutter build apk --release --target-platform=android-arm64`。发布版打包需要签名配置；CI 从 GitHub Secrets 注入。
6. **发布后必须验证更新检查链路**（自动检查失败是静默的，不验证就不知道是否生效）：
   - 确认 `CHANGELOG.md` 已推送到 GitHub `main` 分支；
   - 用 `curl` 验证能拉到最新条目（`curl -s https://raw.githubusercontent.com/aoaim/pubmed-mobile/main/CHANGELOG.md | head -5`）；
   - 在真机/模拟器上打开设置页 →「关于 → 检查更新」，确认弹窗显示新版本与更新日志。

## 11. CHANGELOG.md 格式法则（机器解析，必须严格遵守）

`CHANGELOG.md` 会被 App 内「检查更新」功能自动解析（`ChangelogParser`），**格式错误会导致解析失败**：

```markdown
# PubMed Mobile Changelog

## [0.2.0] - 2026-09-28

### 新增

- 新增：xxx

### 修复

- 修复：yyy

## [0.1.0] - 2026-09-01

### 新增

- 新增：首个正式版本
```

规则：

- 每个版本条目以 `## [x.y.z] - YYYY-MM-DD` 开头（版本号可带 `+build`，如 `0.2.0+1`；日期为发布日期）。
- 每个版本内按 **新增 → 优化 → 修复 → 调整** 的固定顺序分组；没有内容的分类省略，禁止按开发时间交叉追加。
- 分类标题使用 `### 新增`、`### 优化`、`### 修复`、`### 调整`；每条仍以对应的 `- 新增：`、`- 优化：`、`- 修复：`、`- 调整：` 开头。
- 条目必须一行一条；App 解析器会忽略分类标题并读取 `- ` 列表项，GitHub Release 会保留分类标题。
- **新版本在最上面**，按时间倒序排列。
- 版本号必须与 `pubspec.yaml` 的 `version` 一致（不含 `+build` 部分）。
- 发布新版本时**必须**同步更新本文件，否则 App 内检查更新会失效。
- 条目文案中英双语均可，建议与发布内容一致。

## 12. 扩展与其他约定

- 代码注释风格：中文注释为主（与 README 一致），关键设计决策写清"为什么"。
- 用户可见文案中英双语；代码标识符、提交信息用英文。
- 本项目由 AI 辅助开发，README 明确声明非官方应用、含商标与医疗免责声明——新增对外文案时保持该声明完整。
- 修改涉及 NCBI API 调用时，注意遵守其限流要求（见 §4.2），不要移除限流器。
- 新增检索筛选或排序时，将条件贯穿服务端查询、分页、内存缓存、SQLite 搜索历史、恢复搜索和测试；不要只过滤已加载的列表。
- 新增文章元数据时，分别考虑 ESummary 与 EFetch 是否提供该字段、离线缓存、数据库迁移、缺失值处理及原文/译文边界。
- 新功能可增加模块、平台和服务商；优先保持现有公开行为与数据可迁移，再更新文档和发布说明。
