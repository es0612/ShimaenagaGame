# プロジェクト構造 (structure.md)

## 1. ルートディレクトリ構成

プロジェクトの最上位階層は、役割に応じて以下のように明確に分離されています。

```
/
├── ShimaenagaPetGame/      # Xcodeプロジェクトとアプリケーションのソースコード
├── ShimaenagaGameCore/     # コアロジックを管理するローカルSwift Package (設計方針)
├── .kiro/                  # AI開発支援のための仕様書(specs)とステアリング(steering)ファイル
│   ├── specs/
│   └── steering/
├── .gemini/                # Gemini CLIツールの設定
└── ...                     # README.md, .gitignoreなどのプロジェクトファイル
```

## 2. サブディレクトリ構造

### `ShimaenagaPetGame/` (アプリケーションターゲット)
- `ShimaenagaPetGame/ShimaenagaPetGame/`:
  - **Views/**: SwiftUIのViewコンポーネント。
  - **ViewModels/**: Viewに対応するViewModel。`@Observable`オブジェクト。
  - **ShimaenagaPetGameApp.swift**: アプリケーションのエントリーポイント。
  - **Assets.xcassets**: 画像、アイコン、カラーセットなどのアセットファイル。
- `ShimaenagaPetGame/ShimaenagaPetGameTests/`: UIテストや統合テストのターゲット。

### `ShimaenagaGameCore/` (ローカルSPMパッケージ)
- `ShimaenagaGameCore/Sources/`:
  - **Models/**: `ShimaenagaPet`や`GameState`など、SwiftDataで管理されるデータモデル。
  - **GameLogic/**: エサやりや成長判定などのコアなゲームロジック。
  - **BusinessRules/**: 成長条件やステータス減少率などのビジネスルール。
- `ShimaenagaGameCore/Tests/`: `swift test`で実行されるユニットテスト。

## 3. コードの構成パターン

- **関心の分離 (Separation of Concerns)**: UI（View/ViewModel）とビジネスロジック（SPMパッケージ）を厳格に分離します。ViewModelはUIの状態とアクションを管理し、実際の処理はコアロジックに委譲します。
- **データフロー**: ユーザーアクションはViewからViewModelに伝達され、ViewModelが`ShimaenagaGameCore`のロジックを呼び出して状態を更新します。`@Observable`とSwiftDataにより、状態の変更は自動的にViewに反映されます。
- **テスタビリティ**: `ShimaenagaGameCore`はUIフレームワークに依存しないため、単体でのテストが容易です。

## 4. ファイル命名規則

- **型定義**: `UpperCamelCase`（例: `ShimaenagaPet`, `GameViewModel`）。
- **SwiftUI View**: 機能や役割がわかるように命名します（例: `MainGameView.swift`, `StatusBarView.swift`）。
- **ファイルと型の一致**: 1ファイルにつき1つの主要な型を定義し、ファイル名と型名を一致させます。

## 5. 主要なアーキテクチャ原則

- **モダンSwiftの活用**: `async/await`による非同期処理、`@Observable`や`SwiftData`といった最新のフレームワークを積極的に採用し、コードの簡潔性と安全性を高めます。
- **再利用性**: `ShimaenagaGameCore`を独立したパッケージにすることで、将来的に他のプラットフォーム（macOS, watchOSなど）へ展開する際のコード再利用を容易にします。
- **宣言的なUI**: 命令的なUI操作（`UIKit`のような）を避け、状態に基づいてUIが自動的に更新される宣言的なアプローチを徹底します。
