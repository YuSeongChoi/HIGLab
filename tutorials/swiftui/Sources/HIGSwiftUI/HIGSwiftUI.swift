import SwiftUI

/// HIGSwiftUI - Apple Human Interface Guidelines를 따르는 SwiftUI 튜토리얼
///
/// ChefBook 레시피 앱을 만들면서 SwiftUI의 핵심을 마스터합니다.
///
/// ## Topics
///
/// ### Essentials
/// - ``Recipe``
/// - ``RecipeCategory``
/// - ``Ingredient``
///
public struct HIGSwiftUI {
    public init() {}
}

// MARK: - 레시피 데이터 모델

/// 요리 레시피를 나타내는 데이터 모델
public struct Recipe: Identifiable, Hashable {
    public let id: UUID
    public var name: String
    public var description: String
    public var imageName: String
    public var cookingTime: Int // 분 단위
    public var difficulty: Difficulty
    public var category: RecipeCategory
    public var ingredients: [Ingredient]
    public var steps: [String]
    public var isFavorite: Bool
    public var rating: Double
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String,
        imageName: String = "fork.knife",
        cookingTime: Int,
        difficulty: Difficulty,
        category: RecipeCategory,
        ingredients: [Ingredient] = [],
        steps: [String] = [],
        isFavorite: Bool = false,
        rating: Double = 0.0
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageName = imageName
        self.cookingTime = cookingTime
        self.difficulty = difficulty
        self.category = category
        self.ingredients = ingredients
        self.steps = steps
        self.isFavorite = isFavorite
        self.rating = rating
    }
}

/// 요리 난이도
public enum Difficulty: String, CaseIterable, Identifiable {
    case easy = "쉬움"
    case medium = "보통"
    case hard = "어려움"
    
    public var id: String { rawValue }
    
    public var color: String {
        switch self {
        case .easy: return "green"
        case .medium: return "orange"
        case .hard: return "red"
        }
    }
}

/// 레시피 카테고리
public enum RecipeCategory: String, CaseIterable, Identifiable {
    case korean = "한식"
    case western = "양식"
    case japanese = "일식"
    case chinese = "중식"
    case dessert = "디저트"
    case drink = "음료"
    
    public var id: String { rawValue }
    
    public var systemImage: String {
        switch self {
        case .korean: return "leaf.fill"
        case .western: return "fork.knife"
        case .japanese: return "fish.fill"
        case .chinese: return "flame.fill"
        case .dessert: return "birthday.cake.fill"
        case .drink: return "cup.and.saucer.fill"
        }
    }
}

/// 재료 정보
public struct Ingredient: Identifiable, Hashable {
    public let id: UUID
    public var name: String
    public var amount: String
    public var isChecked: Bool
    
    public init(
        id: UUID = UUID(),
        name: String,
        amount: String,
        isChecked: Bool = false
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.isChecked = isChecked
    }
}

// MARK: - 샘플 데이터

public extension Recipe {
    static let sampleRecipes: [Recipe] = [
        Recipe(
            name: "김치찌개",
            description: "구수하고 얼큰한 한국의 대표 찌개",
            imageName: "flame.fill",
            cookingTime: 30,
            difficulty: .easy,
            category: .korean,
            ingredients: [
                Ingredient(name: "김치", amount: "200g"),
                Ingredient(name: "돼지고기", amount: "150g"),
                Ingredient(name: "두부", amount: "1/2모"),
                Ingredient(name: "대파", amount: "1대"),
            ],
            steps: [
                "돼지고기를 한입 크기로 썬다",
                "냄비에 기름을 두르고 돼지고기를 볶는다",
                "김치를 넣고 함께 볶는다",
                "물을 붓고 끓인다",
                "두부와 대파를 넣고 마무리한다"
            ],
            isFavorite: true,
            rating: 4.8
        ),
        Recipe(
            name: "파스타 알리오 올리오",
            description: "마늘과 올리브오일의 심플한 조화",
            imageName: "leaf.fill",
            cookingTime: 20,
            difficulty: .easy,
            category: .western,
            ingredients: [
                Ingredient(name: "스파게티 면", amount: "200g"),
                Ingredient(name: "마늘", amount: "6쪽"),
                Ingredient(name: "올리브오일", amount: "4큰술"),
                Ingredient(name: "페페론치노", amount: "2개"),
            ],
            steps: [
                "파스타 면을 끓는 물에 삶는다",
                "마늘을 얇게 슬라이스한다",
                "올리브오일에 마늘을 볶는다",
                "삶은 면과 면수를 넣고 섞는다"
            ],
            isFavorite: false,
            rating: 4.5
        ),
        Recipe(
            name: "연어 덮밥",
            description: "신선한 연어와 밥의 완벽한 만남",
            imageName: "fish.fill",
            cookingTime: 15,
            difficulty: .easy,
            category: .japanese,
            ingredients: [
                Ingredient(name: "연어 (회)", amount: "150g"),
                Ingredient(name: "밥", amount: "1공기"),
                Ingredient(name: "아보카도", amount: "1/2개"),
                Ingredient(name: "간장", amount: "2큰술"),
            ],
            steps: [
                "밥을 그릇에 담는다",
                "연어를 썰어 올린다",
                "아보카도를 썰어 곁들인다",
                "간장 소스를 뿌린다"
            ],
            isFavorite: true,
            rating: 4.9
        ),
        Recipe(
            name: "티라미수",
            description: "이탈리아의 대표 디저트",
            imageName: "birthday.cake.fill",
            cookingTime: 45,
            difficulty: .medium,
            category: .dessert,
            ingredients: [
                Ingredient(name: "마스카포네 치즈", amount: "500g"),
                Ingredient(name: "에스프레소", amount: "200ml"),
                Ingredient(name: "레이디핑거", amount: "24개"),
                Ingredient(name: "코코아 파우더", amount: "적당량"),
            ],
            steps: [
                "마스카포네 크림을 만든다",
                "레이디핑거를 에스프레소에 적신다",
                "층층이 쌓아올린다",
                "냉장고에서 4시간 굳힌다",
                "코코아 파우더를 뿌린다"
            ],
            isFavorite: false,
            rating: 4.7
        ),
    ]
    
    static let sample = sampleRecipes[0]
}
