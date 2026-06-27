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
    ├── Clock-Widget/                       … メインアプリ（デザイン編集アプリ・このフォルダは同期グループで自動追加）
    │   ├── Clock_WidgetApp.swift           … アプリのエントリポイント（@main）
    │   ├── ContentView.swift               … 編集画面の合成（共通設定＋各EditorSectionを Form に配置）
    │   ├── ColorEditorSection.swift        … 編集UI: 色・背景（A）
    │   ├── AnalogEditorSection.swift       … 編集UI: アナログ意匠（B）
    │   ├── DotMatrixEditorSection.swift    … 編集UI: ドット意匠（C）
    │   ├── DigitalEditorSection.swift      … 編集UI: デジタル書式（D）
    │   ├── InfoEditorSection.swift         … 編集UI: 付加情報（E）
    │   ├── PresetEditorSection.swift       … 編集UI: プリセット保存/適用（F）
    │   ├── SizeEditorSection.swift         … 編集UI: 盤面サイズ（faceScale Slider, 全スタイル共通）
    │   ├── FullScreenClockView.swift       … アプリ内・縦横対応フルスクリーン時計盤（夜間減光モード）
    │   └── Assets.xcassets                 … アイコン・色などのアセット
    ├── Shared/                             … 両ターゲットでコンパイル（pbxprojに明示登録：新規追加時は要結線）
    │   ├── ClockFaceModel.swift            … 全デザイン設定モデル(Codable/寛容デコーダ, faceScale含む)+各enum+Color(hex:)
    │   ├── ClockFaceStore.swift            … 現在デザインの App Group 永続化（load/save→reload）
    │   ├── ClockPreset.swift               … プリセット型 + ClockPresetStore（App Group, CRUD）
    │   ├── ClockFaceView.swift             … 合成(背景込)＋ ClockFaceContent(前景のみ・faceScale反映。ウィジェットは前景のみ使用)
    │   ├── ClockBackgroundView.swift       … 背景描画（単色/線形/放射グラデ・不透明度）
    │   ├── AnalogFaceView.swift            … アナログ盤（マーカー種別/密度・針形状, Canvas）
    │   ├── DotMatrixFaceView.swift         … ドット時計（5x7・形状/グロー, Canvas）
    │   ├── DigitalFaceView.swift           … デジタル（フォント/書式/12-24h）
    │   └── ComplicationOverlay.swift       … 付加情報の重ね表示（日付/曜日/カスタム文字）
    └── ClockWidget/                        … WidgetKit 拡張（同期グループで自動追加）
        ├── ClockWidget.swift               … AppIntentConfiguration(全サイズ)＋分単位Provider＋ConfigureClockIntent。背景は containerBackgroundで全面、前景は ClockFaceContent
        └── ClockWidgetBundle.swift         … 拡張の @main（WidgetBundle）
```

- **App Group**: `group.com.Clock-Widget`（両 entitlements に有効）。アプリ↔ウィジェットのデザイン/プリセット共有に使用。Simulator／実機（近年は無料 Personal Team でも App Group 可）で動作。ストアは `UserDefaults(suiteName:) ?? .standard`。
- **ターゲット**: `Clock-Widget`（アプリ）/ `ClockWidgetExtension`（拡張, Bundle ID `com.Clock-Widget.ClockWidget`）
- **編集UIの規約**: 各 `*EditorSection` は `@Binding var design` を受け、`body` は `Section{…}` を返す（`ContentView` の `Form` 内に配置）。新スタイル/機能の追加はこの分割に倣う。
- **ウィジェットは2系統で編集可**: `ConfigureClockIntent`（AppIntents）の「デザイン元」で選択 — `followApp`=アプリ(App Group)編集に追従 / `custom`=ウィジェット個別設定（色は `ColorChoice` パレット）。アプリ側 `ContentView`/`*EditorSection` の編集は followApp のウィジェットへ反映される。
- **ウィジェットサイズ/背景/盤面サイズ**: `supportedFamilies` は systemSmall〜systemExtraLarge（全サイズ。extraLargeはiPadのみ表示）。背景は `containerBackground` に `ClockBackgroundView` を置き**ウィジェット全面**に適用（内側の枠ではない）。盤面サイズは `faceScale`（アプリ=Slider 0.4〜1.0 / ウィジェット個別=`FaceSizeChoice` 小中大最大）。
- **アプリ内編集UI と プリセット機能は「アプリ内・縦横対応の時計盤」にも活用**。全画面表示は `FullScreenClockView`（夜間減光モード付き）。
- **Shared 追加時の注意**: `Shared/` は pbxproj に明示登録のため、新規ファイルは両ターゲットの Sources へ結線が必要（同期グループではない）。
- ビルド検証済み: iOS Simulator(26.x) 向け `BUILD SUCCEEDED`、編集UI・各スタイル描画を実機シミュレータで確認。

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
