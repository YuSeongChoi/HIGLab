import SwiftUI
import Observation

// MARK: - CartFlow: 배송지 편집 뷰
// 중첩 Observable에서 @Bindable 활용

struct ShippingAddressEditView: View {
    // 내부 Observable 객체에 @Bindable 적용
    @Bindable var address: ShippingAddress
    var onSave: (() -> Void)?
    
    var body: some View {
        Form {
            Section("받는 사람") {
                TextField("이름", text: $address.recipientName)
                TextField("연락처", text: $address.phoneNumber)
                    .keyboardType(.phonePad)
            }
            
            Section("주소") {
                HStack {
                    TextField("우편번호", text: $address.postalCode)
                        .keyboardType(.numberPad)
                    
                    Button("검색") {
                        // 주소 검색 로직
                    }
                    .buttonStyle(.bordered)
                }
                
                TextField("주소", text: $address.address)
                TextField("상세주소", text: $address.detailAddress)
            }
            
            Section {
                Toggle("기본 배송지로 설정", isOn: $address.isDefault)
            }
            
            if let onSave {
                Section {
                    Button("저장") {
                        onSave()
                    }
                    .disabled(!address.isValid)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle("배송지 편집")
    }
}

// MARK: - 주문 화면에서 배송지 섹션

struct CheckoutShippingSection: View {
    var orderStore: OrderStore
    @State private var isEditingAddress = false
    
    var body: some View {
        Section("배송지") {
            // orderStore.shippingAddress의 프로퍼티들을 직접 접근
            // → 각 프로퍼티 변경 시 이 섹션만 업데이트됨
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(orderStore.shippingAddress.recipientName)
                        .font(.headline)
                    
                    if orderStore.shippingAddress.isDefault {
                        Text("기본")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.blue.opacity(0.1))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }
                }
                
                Text(orderStore.shippingAddress.phoneNumber)
                    .foregroundStyle(.secondary)
                
                Text(orderStore.shippingAddress.fullAddress)
                    .font(.subheadline)
            }
            
            Button("배송지 변경") {
                isEditingAddress = true
            }
        }
        .sheet(isPresented: $isEditingAddress) {
            NavigationStack {
                ShippingAddressEditView(
                    address: orderStore.shippingAddress
                ) {
                    isEditingAddress = false
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("취소") {
                            isEditingAddress = false
                        }
                    }
                }
            }
        }
    }
}
