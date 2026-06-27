# CLAUDE.md
このmarkdownファイルは、**CCが正しく、一貫したコーディングや作業を維持するために作成されたもの**で、CCはすべてこれに従ってください。

##1. プロジェクトの目的
- iPhone(14)のホーム画面から、独自の、サイズや時計盤などの自由度の高い時計ウィジェットを表示できるようにする
- アプリから直感的に時計ウィジェットのデザイン編集をできるようにする
- 基本的にバッテリー効率の問題があるため、時計盤は分単位での更新とする
- アナログのドット集まりの時計から一般的な時計盤まで対応する
##2. ファイル構成

```
Clock-Widget/                              … リポジトリルート
├── CLAUDE.md                              … 本ファイル（作業ルール）
└── Clock-Widget/                          … Xcode プロジェクトルート（SRCROOT）
    ├── Clock-Widget.xcodeproj             … プロジェクト定義（2ターゲット）
    ├── Clock-Widget.entitlements          … アプリ用 App Group 設定
    ├── ClockWidgetExtension.entitlements  … 拡張用 App Group 設定
    ├── ClockWidgetExtension-Info.plist    … 拡張の NSExtension 定義
    ├── Clock-Widget/                       … メインアプリ（デザイン編集アプリ）
    │   ├── Clock_WidgetApp.swift           … アプリのエントリポイント（@main）
    │   ├── ContentView.swift               … デザイン編集UI（スタイル/色/秒/ドットサイズ）
    │   └── Assets.xcassets                 … アイコン・色などのアセット
    ├── Shared/                             … アプリと拡張の両ターゲットでコンパイル
    │   ├── ClockFaceModel.swift            … デザインのデータモデル（Codable）+ Color(hex:)
    │   ├── ClockFaceStore.swift            … App Group 永続化（load/save→reload）
    │   └── ClockFaceView.swift             … 時計盤描画（analog/dotMatrix/digital, Canvas）
    └── ClockWidget/                        … WidgetKit 拡張ターゲットのソース
        ├── ClockWidget.swift               … TimelineProvider（分単位更新）+ Widget
        └── ClockWidgetBundle.swift         … 拡張の @main（WidgetBundle）
```

- **App Group**: `group.com.Clock-Widget`（アプリ↔拡張のデザイン共有）
- **ターゲット**: `Clock-Widget`（アプリ）/ `ClockWidgetExtension`（拡張, Bundle ID `com.Clock-Widget.ClockWidget`）
- ビルド検証済み: iOS Simulator(26.x) 向け `BUILD SUCCEEDED`

##3. 技術スタック
- **言語**: Swift 5.0
- **UI**: SwiftUI
- **ウィジェット**: WidgetKit（ホーム画面ウィジェット）
- **時計盤描画**: SwiftUI Canvas / TimelineProvider（分単位更新でバッテリー効率を確保）
- **アプリ↔拡張のデータ共有**: App Group + 共有モデル（Codable、UserDefaults(suiteName:) 等）
- **開発環境**: Xcode（日常の開発・確認は iOS Simulator 主軸、iOS 27 beta 実機は最終確認用）
- **ターゲット**: iOS 18.0 以上（iPhone 14 を主対象）
- **Bundle ID**: `com.Clock-Widget`

##4. コード編集などの際の要項
- 基本的なmarkdownファイル読み込みやそれの更新、git pushなど以外の、一般的なコード編集は、**合計作業量が適切な場合は3体のモデルに分割**し、それぞれに同時並行で進めることが可能なタスクを割り振り、作業が終わり次第一つのモデルに統合すること
