# Clock-Widget

iPhone のホーム画面に、**アプリで編集したお好みのデザインの時計盤をウィジェットとして配置できる**アプリケーションです。

アナログ・ドット集合体・デジタルの時計盤を、色やサイズを含めてアプリ上で直感的にカスタマイズし、その設定を WidgetKit ウィジェットへ反映します。

## 主な目的

- iPhone(14) のホーム画面から、サイズや時計盤などの自由度の高い独自の時計ウィジェットを表示する
- アプリ上で直感的に時計ウィジェットのデザインを編集できるようにする
- バッテリー効率のため、時計盤の更新は**分単位**とする
- アナログのドット集合体の時計から一般的な時計盤まで対応する

## 機能

- **3 つの時計スタイル**: ドット時計（dotMatrix）／アナログ／デジタル
- **デザイン編集 UI**: 前景色・背景色（ColorPicker）、秒表示の切り替え、ドットサイズ調整
- **リアルタイムプレビュー**: 編集画面に時計盤プレビューを表示
- **ウィジェット連携**: App Group 経由で編集内容をホーム画面ウィジェットへ共有
- **分単位更新**: TimelineProvider により分単位で更新しバッテリー消費を抑制

## 技術スタック

- **言語**: Swift 5.0
- **UI フレームワーク**: SwiftUI
- **ウィジェット**: WidgetKit（ホーム画面ウィジェット）
- **時計盤描画**: SwiftUI Canvas / TimelineProvider（分単位更新）
- **アプリ↔拡張のデータ共有**: App Group + 共有 Codable モデル（`group.com.Clock-Widget`）
- **対応 OS**: iOS 18.0 以上（iPhone 14 を主対象）
- **開発環境**: Xcode（日常確認は iOS Simulator 主軸）

## プロジェクト構成

```
Clock-Widget/                              … リポジトリルート
├── CLAUDE.md                              … 開発方針・作業ルール
├── README.md
└── Clock-Widget/                          … Xcode プロジェクトルート
    ├── Clock-Widget.xcodeproj             … プロジェクト定義（2 ターゲット）
    ├── Clock-Widget.entitlements          … アプリ用 App Group 設定
    ├── ClockWidgetExtension.entitlements  … 拡張用 App Group 設定
    ├── ClockWidgetExtension-Info.plist    … 拡張の NSExtension 定義
    ├── Clock-Widget/                       … メインアプリ（デザイン編集アプリ）
    │   ├── Clock_WidgetApp.swift           … アプリのエントリポイント（@main）
    │   ├── ContentView.swift               … デザイン編集 UI
    │   └── Assets.xcassets                 … アイコン・色などのアセット
    ├── Shared/                             … アプリ・拡張の両ターゲットで共有
    │   ├── ClockFaceModel.swift            … デザインのデータモデル（Codable）+ Color(hex:)
    │   ├── ClockFaceStore.swift            … App Group 永続化（load/save）
    │   └── ClockFaceView.swift             … 時計盤描画（analog/dotMatrix/digital, Canvas）
    └── ClockWidget/                        … WidgetKit 拡張ターゲット
        ├── ClockWidget.swift               … TimelineProvider（分単位更新）+ Widget
        └── ClockWidgetBundle.swift         … 拡張の @main（WidgetBundle）
```

### ターゲット / App Group

- **App Group**: `group.com.Clock-Widget`（アプリ↔拡張のデザイン共有）
- **アプリ**: `Clock-Widget`（Bundle ID `com.Clock-Widget`）
- **拡張**: `ClockWidgetExtension`（Bundle ID `com.Clock-Widget.ClockWidget`）

## ビルド方法

1. `Clock-Widget/Clock-Widget.xcodeproj` を Xcode で開く
2. 実機（iPhone）またはシミュレータ（iOS 18.0+）を選択してビルド・実行
3. ウィジェットを試す場合は、ホーム画面に「時計ウィジェット」を追加し、アプリ側で編集した内容が反映されることを確認する

> ビルド検証: iOS Simulator 向けに `BUILD SUCCEEDED` を確認済み。

## 今後の予定

- [ ] ウィジェットのサイズファミリ（small / medium / large）対応の拡充
- [ ] 時計盤デザインのプリセット追加
- [ ] フォント・目盛りなどの編集項目の拡張
