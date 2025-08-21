# Design Document

## Overview

シマエナガ育成ゲームは、SwiftUIを使用したiOS向けネイティブアプリです。MVVM（Model-View-ViewModel）アーキテクチャパターンを採用し、子ども向けの直感的なUIと滑らかなアニメーションを提供します。アプリは単一画面で完結し、複雑なナビゲーションを避けることで、幼稚園から小学生低学年の子どもでも迷わず操作できるよう設計されています。

## Architecture

### アーキテクチャパターン: MVVM + Local SPM Package

```
iOS App Target
├── Views (SwiftUI)
├── ViewModels (@Observable)
└── ShimaenagaGameCore (Local SPM Package)
    ├── Models
    ├── Game Logic
    ├── Business Rules
    └── Data Management
```

- **iOS App Target**: SwiftUIビュー、ViewModel、UI関連コード
- **ShimaenagaGameCore Package**: ビジネスロジック、ゲームルール、データモデル
- **分離の利点**: 高速テスト実行、TDD促進、コード再利用性向上

### 状態管理

- `@Observable`マクロを使用したモダンなリアクティブ状態管理
- `@State`による局所的なUI状態管理（アニメーション、一時的な表示状態）
- SwiftDataによる永続化（シマエナガの状態、写真メタデータ、継続日数）

## Components and Interfaces

### 1. Core Models (ShimaenagaGameCore Package)

#### ShimaenagaPet
```swift
// ShimaenagaGameCore/Sources/Models/ShimaenagaPet.swift
public struct ShimaenagaPet: Codable, Sendable {
    public var id: UUID
    public var name: String
    public var growthStage: GrowthStage
    public var hungerLevel: Int // 0-100
    public var happinessLevel: Int // 0-100
    public var healthLevel: Int // 0-100
    public var lastFeedTime: Date
    public var lastPlayTime: Date
    public var birthDate: Date
    public var isHatched: Bool
    
    public init(name: String = "シマエナガ") {
        self.id = UUID()
        self.name = name
        self.growthStage = .egg
        self.hungerLevel = 50
        self.happinessLevel = 50
        self.healthLevel = 100
        self.lastFeedTime = Date()
        self.lastPlayTime = Date()
        self.birthDate = Date()
        self.isHatched = false
    }
}

public enum GrowthStage: String, CaseIterable, Codable {
    case egg = "egg"
    case baby = "baby"
    case child = "child"
    case adult = "adult"
}
```

#### GameState
```swift
import SwiftData

@Model
class GameState {
    var pet: ShimaenagaPet?
    var continuousDays: Int
    var lastOpenDate: Date
    var totalPhotos: Int
    var roomDecorations: [RoomDecoration]
    var availableItems: [DecorationItem]
    
    init(continuousDays: Int = 0, lastOpenDate: Date = Date(), totalPhotos: Int = 0) {
        self.continuousDays = continuousDays
        self.lastOpenDate = lastOpenDate
        self.totalPhotos = totalPhotos
        self.roomDecorations = []
        self.availableItems = DecorationItem.defaultItems
    }
}

@Model
class RoomDecoration {
    var item: DecorationItem
    var position: CGPoint
    var dateAdded: Date
    
    init(item: DecorationItem, position: CGPoint) {
        self.item = item
        self.position = position
        self.dateAdded = Date()
    }
}

@Model
class PhotoMemory {
    var imageData: Data
    var dateTaken: Date
    var petGrowthStage: GrowthStage
    
    init(imageData: Data, petGrowthStage: GrowthStage) {
        self.imageData = imageData
        self.dateTaken = Date()
        self.petGrowthStage = petGrowthStage
    }
}
```

### 2. View Components

#### MainGameView
- メインゲーム画面
- シマエナガの表示とインタラクション
- ステータス表示
- アクションボタン群

#### ShimaenagaView
- シマエナガキャラクターの表示
- アニメーション制御
- タップインタラクション

#### StatusBarView
- 満腹度、幸福度、健康度の表示
- 子ども向けアイコン（ハート、星、笑顔など）
- カラフルなプログレスバー

#### ActionButtonsView
- エサやり、遊び、写真撮影、デコレーションボタン
- 大きなタップエリア（最小44pt）
- アイコン + テキストの組み合わせ

#### DecorationView
- 部屋のデコレーション表示
- ドラッグ&ドロップ機能
- アイテム配置管理

#### PhotoAlbumView
- 撮影した写真の一覧表示
- グリッドレイアウト
- 写真の拡大表示

### 3. ViewModels

#### GameViewModel
```swift
import SwiftData

@MainActor
@Observable
class GameViewModel {
    var gameState: GameState
    var isFeeding: Bool = false
    var isPlaying: Bool = false
    var showPhotoAlbum: Bool = false
    var showDecorationMode: Bool = false
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.gameState = loadOrCreateGameState()
    }
    
    func feedPet()
    func playWithPet()
    func takePhoto()
    func updatePetStatus()
    func checkGrowthProgress()
    
    private func loadOrCreateGameState() -> GameState
    private func saveGameState()
}
```

## Data Models

### 永続化戦略

#### SwiftData
- モダンなCore Dataの後継として、型安全なデータ永続化
- `@Model`マクロによる簡潔なモデル定義
- 自動的なリレーションシップ管理

```swift
import SwiftData

struct DataManager {
    static func createModelContainer() -> ModelContainer {
        let schema = Schema([
            ShimaenagaPet.self,
            GameState.self,
            RoomDecoration.self,
            PhotoMemory.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
```

#### Photo Storage
- 写真データはSwiftDataのPhotoMemoryモデルに保存
- バイナリデータとして効率的に管理

### データフロー

```
User Action → ViewModel (@Observable) → SwiftData Model Update → View Refresh
     ↓
SwiftData Persistence Layer (Automatic)
```

## Error Handling

### エラー処理方針

1. **子ども向けの優しいエラーメッセージ**
   - 技術的な詳細は隠す
   - 絵文字やイラストを使用
   - 解決方法を簡潔に提示

2. **グレースフルデグラデーション**
   - 写真撮影失敗時はデフォルト画像を使用
   - データ読み込み失敗時は初期状態で開始
   - アニメーション失敗時は静的表示にフォールバック

3. **ログ記録**
   - 開発者向けの詳細ログ
   - クラッシュ防止のための例外処理

```swift
enum GameError: LocalizedError {
    case feedingFailed
    case photoSaveFailed
    case dataLoadFailed
    
    var errorDescription: String? {
        switch self {
        case .feedingFailed:
            return "🍎 エサをあげられませんでした。もう一度試してみてね！"
        case .photoSaveFailed:
            return "📸 写真を保存できませんでした。もう一度撮ってみてね！"
        case .dataLoadFailed:
            return "💾 データを読み込めませんでした。新しく始めましょう！"
        }
    }
}
```

## Animation Strategy

### SwiftUIアニメーション活用

#### 1. 基本アニメーション
- `withAnimation`を使用した状態変化のアニメーション
- `.easeInOut`、`.spring`、`.bouncy`などの子ども向けアニメーション

#### 2. キャラクターアニメーション
- `phaseAnimator`を使用した複数段階アニメーション
- 孵化、成長、反応アニメーション

```swift
// 孵化アニメーション例
.phaseAnimator([.egg, .cracking, .hatching, .baby]) { content, phase in
    content
        .scaleEffect(phase.scaleEffect)
        .rotationEffect(phase.rotation)
        .opacity(phase.opacity)
} animation: { phase in
    switch phase {
    case .egg: .smooth
    case .cracking: .easeInOut(duration: 0.5)
    case .hatching: .spring(duration: 1.0, bounce: 0.3)
    case .baby: .bouncy
    }
}
```

#### 3. インタラクションアニメーション
- タップ時の拡大縮小
- ボタンのバウンス効果
- ステータス変化の滑らかな遷移

#### 4. 背景アニメーション
- 微細な浮遊アニメーション
- 季節や時間による背景変化

### パフォーマンス考慮

- アニメーション中の重い処理を避ける
- 60FPSを維持するための最適化
- バッテリー消費を抑えた設計

## Testing Strategy

### 1. Unit Testing (SwiftTesting + SPM)

#### Core Logic Testing (ShimaenagaGameCore Package)
```swift
// ShimaenagaGameCore/Tests/ShimaenagaGameCoreTests/PetLogicTests.swift
import Testing
@testable import ShimaenagaGameCore

@Suite("Pet Logic Tests")
struct PetLogicTests {
    @Test("Feeding increases hunger level")
    func feedingIncreasesHungerLevel() async throws {
        var pet = ShimaenagaPet()
        let gameLogic = GameLogic()
        
        let updatedPet = gameLogic.feedPet(pet)
        #expect(updatedPet.hungerLevel > pet.hungerLevel)
    }
    
    @Test("Growth stage progression works correctly")
    func growthStageProgression() async throws {
        let gameLogic = GameLogic()
        let pet = ShimaenagaPet()
        
        let canGrow = gameLogic.canPetGrow(pet)
        #expect(canGrow != nil)
    }
    
    @Test("Status decay over time")
    func statusDecayOverTime() async throws {
        let gameLogic = GameLogic()
        var pet = ShimaenagaPet()
        pet.lastFeedTime = Date().addingTimeInterval(-3600) // 1 hour ago
        
        let updatedPet = gameLogic.updatePetStatus(pet)
        #expect(updatedPet.hungerLevel < pet.hungerLevel)
    }
}

// 実行: swift test (シミュレータ不要、高速実行)
```

#### ViewModel Testing (iOS App Target)
```swift
// Tests/ViewModelTests.swift
import Testing
import ShimaenagaGameCore

@Suite("GameViewModel Tests")
struct GameViewModelTests {
    @Test("Feed pet updates hunger level")
    @MainActor
    func feedPetUpdatesHungerLevel() async throws {
        let viewModel = GameViewModel(mockContext: true)
        let initialHunger = viewModel.gameState.pet?.hungerLevel ?? 0
        
        await viewModel.feedPet()
        
        let finalHunger = viewModel.gameState.pet?.hungerLevel ?? 0
        #expect(finalHunger > initialHunger)
    }
}
```

### 2. UI Testing

#### 基本操作テスト
- エサやりボタンのタップ
- 遊びボタンのタップ
- 写真撮影機能
- デコレーション機能

#### アクセシビリティテスト
- VoiceOverサポート
- Dynamic Typeサポート
- コントラスト比の確認

### 3. Integration Testing

#### データ永続化テスト
- SwiftDataによるゲーム状態の保存・読み込み
- PhotoMemoryモデルの写真データ管理
- アプリ再起動時のSwiftDataからの状態復元

#### パフォーマンステスト
- アニメーション中のフレームレート
- メモリ使用量
- バッテリー消費

### 4. Child User Testing Considerations

実際の子どもによるテストは実装後に行うため、設計段階では以下を考慮：

- 直感的な操作性
- 視覚的フィードバックの明確さ
- エラー時の分かりやすさ
- 飽きさせない工夫

## Technical Specifications

### 対応OS
- iOS 17.0以上（SwiftData、@Observable、SwiftTestingの最新機能活用のため）

### デバイス対応
- iPhone（全サイズ）
- iPad（ユニバーサルアプリとして対応）

### パフォーマンス目標
- 起動時間: 2秒以内
- アニメーション: 60FPS維持
- メモリ使用量: 50MB以下

### アクセシビリティ
- VoiceOverサポート
- Dynamic Typeサポート
- ハイコントラストモード対応
- スイッチコントロール対応

## Security and Privacy

### プライバシー保護
- 個人情報の収集なし
- 外部通信なし（完全オフライン）
- 写真は端末内のみに保存

### データ保護
- 写真データの暗号化
- アプリ削除時の完全データ削除

## Localization

### 初期対応言語
- 日本語（メイン）

### 将来的な多言語対応準備
- 文字列のローカライゼーション対応
- 画像内テキストの分離
- 右から左への言語対応準備
## Mode
rn Swift Features Integration

### @Observable マクロ
- iOS 17で導入された新しい観測可能オブジェクト
- `@ObservableObject`と`@Published`の代替として、より簡潔な記述
- 自動的な変更通知とSwiftUIとの統合

### SwiftData
- Core Dataの後継として設計されたモダンなデータ永続化フレームワーク
- `@Model`マクロによる宣言的なモデル定義
- 型安全性とSwiftUIとの深い統合

### SwiftTesting
- XCTestの後継として開発された新しいテストフレームワーク
- より表現力豊かなテスト記述
- 非同期テストの改善されたサポート

### Structured Concurrency
- async/awaitを活用した非同期処理
- アニメーション中の重い処理の最適化
- データ読み込み処理の改善

```swift
// 例：非同期でのペット状態更新
@MainActor
func updatePetStatusAsync() async {
    await withTaskGroup(of: Void.self) { group in
        group.addTask { await self.updateHungerLevel() }
        group.addTask { await self.updateHappinessLevel() }
        group.addTask { await self.updateHealthLevel() }
    }
}
```## SPM Lo
cal Package Strategy

### Package Structure
```
ShimaenagaPetGame/
├── ShimaenagaPetGame/ (iOS App Target)
│   ├── Views/
│   ├── ViewModels/
│   └── Resources/
├── ShimaenagaGameCore/ (Local SPM Package)
│   ├── Package.swift
│   ├── Sources/
│   │   ├── Models/
│   │   ├── GameLogic/
│   │   ├── BusinessRules/
│   │   └── DataManagement/
│   └── Tests/
│       └── ShimaenagaGameCoreTests/
└── Package.swift (Workspace level)
```

### Package.swift Configuration
```swift
// ShimaenagaGameCore/Package.swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ShimaenagaGameCore",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ShimaenagaGameCore",
            targets: ["ShimaenagaGameCore"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ShimaenagaGameCore",
            dependencies: []
        ),
        .testTarget(
            name: "ShimaenagaGameCoreTests",
            dependencies: ["ShimaenagaGameCore"]
        ),
    ]
)
```

### Core Logic Separation Benefits

#### 1. 高速テスト実行
- `swift test`でシミュレータ不要
- CI/CDでの実行時間短縮
- TDDサイクルの高速化

#### 2. 依存関係の明確化
- UIKit/SwiftUI依存の排除
- ビジネスロジックの純粋性保持
- テスタビリティの向上

#### 3. コード再利用性
- 将来的なmacOS/watchOS対応時の共通コード
- 異なるUI実装での同一ロジック利用

#### 4. 開発効率向上
- ロジック変更時のコンパイル時間短縮
- 並行開発の促進（UI担当者とロジック担当者）

### Core Package Contents

#### GameLogic
```swift
// ShimaenagaGameCore/Sources/GameLogic/GameLogic.swift
public struct GameLogic {
    public init() {}
    
    public func feedPet(_ pet: ShimaenagaPet) -> ShimaenagaPet {
        var updatedPet = pet
        updatedPet.hungerLevel = min(100, pet.hungerLevel + 20)
        updatedPet.lastFeedTime = Date()
        return updatedPet
    }
    
    public func playWithPet(_ pet: ShimaenagaPet) -> ShimaenagaPet {
        var updatedPet = pet
        updatedPet.happinessLevel = min(100, pet.happinessLevel + 15)
        updatedPet.lastPlayTime = Date()
        return updatedPet
    }
    
    public func updatePetStatus(_ pet: ShimaenagaPet) -> ShimaenagaPet {
        // Time-based status decay logic
    }
    
    public func canPetGrow(_ pet: ShimaenagaPet) -> GrowthStage? {
        // Growth condition logic
    }
}
```

#### BusinessRules
```swift
// ShimaenagaGameCore/Sources/BusinessRules/GrowthRules.swift
public struct GrowthRules {
    public static func timeRequiredForGrowth(from stage: GrowthStage) -> TimeInterval {
        switch stage {
        case .egg: return 24 * 60 * 60 // 24 hours
        case .baby: return 48 * 60 * 60 // 48 hours
        case .child: return 72 * 60 * 60 // 72 hours
        case .adult: return 0 // No further growth
        }
    }
    
    public static func minimumStatsForGrowth(to stage: GrowthStage) -> (hunger: Int, happiness: Int, health: Int) {
        switch stage {
        case .baby: return (60, 50, 80)
        case .child: return (70, 60, 85)
        case .adult: return (80, 70, 90)
        case .egg: return (0, 0, 0)
        }
    }
}
```

### Testing Strategy with SPM

#### Fast Feedback Loop
1. `swift test` - Core logic tests (seconds)
2. iOS Simulator tests - Integration tests (minutes)
3. Device tests - UI/Performance tests (when needed)

#### TDD Workflow
1. Write failing test in ShimaenagaGameCore
2. Implement logic to pass test
3. Refactor with confidence
4. Integrate with SwiftUI views
5. Add integration tests if needed

This architecture provides a solid foundation for maintainable, testable, and scalable code while enabling rapid development cycles.