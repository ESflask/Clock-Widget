# CLAUDE.md
このmarkdownファイルは、**CCが正しく、一貫したコーディングや作業を維持するために作成されたもの**で、CCはすべてこれに従ってください。

##1. プロジェクトの目的
- iPhone(14)のホーム画面から、独自の、サイズや時計盤などの自由度の高い時計ウィジェットを表示できるようにする
- アプリから直感的に時計ウィジェットのデザイン編集をできるようにする
- 基本的にバッテリー効率の問題があるため、時計盤は分単位での更新とする
- アナログのドット集まりの時計から一般的な時計盤まで対応する
##2. ファイル構成
> `[ ]` は今後追加予定（未作成）。現状は Xcode のデフォルトアプリテンプレート段階。

```
Clock-Widget/                         … リポジトリルート
├── CLAUDE.md                         … 本ファイル（作業ルール）
└── Clock-Widget/                     … Xcode プロジェクトルート
    ├── Clock-Widget.xcodeproj        … プロジェクト定義
    └── Clock-Widget/                 … メインアプリ（編集用アプリ本体）
        ├── Clock_WidgetApp.swift     … アプリのエントリポイント（@main）
        ├── ContentView.swift         … ルート画面（→ 将来デザイン編集UIに置換）
        └── Assets.xcassets           … アイコン・色などのアセット
[ ] ClockWidgetExtension/             … WidgetKit 拡張ターゲット（時計盤の表示本体）
[ ] Shared/                           … アプリと拡張で共有するモデル・描画ロジック
        [ ] ClockFaceModel.swift      … 時計盤デザインのデータモデル（Codable）
        [ ] ClockFaceRenderer.swift   … 時計盤描画（ドット集合〜一般的な盤面）
[ ] App Group                         … アプリ↔拡張間でデザイン設定を共有する手段
```

##3. 技術スタック
- **言語**: Swift 5.0
- **UI**: SwiftUI
- **ウィジェット**: WidgetKit（ホーム画面ウィジェット）
- **時計盤描画**: SwiftUI Canvas / TimelineProvider（分単位更新でバッテリー効率を確保）
- **アプリ↔拡張のデータ共有**: App Group + 共有モデル（Codable、UserDefaults(suiteName:) 等）
- **開発環境**: Xcode
- **ターゲット**: iOS 26.2 以上（iPhone 14 を主対象）
- **Bundle ID**: `com.Clock-Widget`

##4. コード編集などの際の要項
- 基本的なmarkdownファイル読み込みやそれの更新、git pushなど以外の、一般的なコード編集は、合計作業量が適切な場合は3体のモデルに分割し、それぞれに同時並行で進めることが可能なタスクを割り振り、作業が終わり次第一つのモデルに統合すること
