import SwiftUI

// MARK: - 설정 뷰
// 앱 설정을 관리하는 화면

struct SettingsView: View {
    
    // MARK: - Environment
    
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var geofenceManager: GeofenceManager
    
    // MARK: - State
    
    /// 권한 안내 알림 표시
    @State private var showPermissionGuide = false
    
    /// 데이터 삭제 확인 표시
    @State private var showDeleteDataConfirmation = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                // 권한 섹션
                permissionSection
                
                // 위치 정확도 섹션
                accuracySection
                
                // 추적 설정 섹션
                trackingSection
                
                // 백그라운드 설정 섹션
                backgroundSection
                
                // 데이터 관리 섹션
                dataSection
                
                // 앱 정보 섹션
                aboutSection
            }
            .navigationTitle("설정")
            .alert("위치 권한 안내", isPresented: $showPermissionGuide) {
                Button("설정으로 이동") {
                    locationManager.openSettings()
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("위치 권한을 변경하려면 설정 앱에서 '위치 서비스' 설정을 변경해주세요.")
            }
            .alert("모든 데이터 삭제", isPresented: $showDeleteDataConfirmation) {
                Button("취소", role: .cancel) {}
                Button("삭제", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("저장된 모든 경로와 지오펜스가 삭제됩니다. 이 작업은 되돌릴 수 없습니다.")
            }
        }
    }
    
    // MARK: - 권한 섹션
    
    private var permissionSection: some View {
        Section {
            // 현재 권한 상태
            HStack {
                Label("위치 권한", systemImage: "location.fill")
                
                Spacer()
                
                Text(locationManager.permissionStatus.displayText)
                    .foregroundColor(.secondary)
                
                Circle()
                    .fill(permissionStatusColor)
                    .frame(width: 8, height: 8)
            }
            
            // 권한 변경 버튼
            Button {
                showPermissionGuide = true
            } label: {
                HStack {
                    Text("권한 설정 변경")
                    Spacer()
                    Image(systemName: "arrow.up.forward.app")
                }
            }
            
            // 항상 허용 요청 (필요시)
            if locationManager.permissionStatus == .authorizedWhenInUse {
                Button {
                    locationManager.requestAlwaysAuthorization()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("'항상' 권한 요청")
                            Text("백그라운드에서도 위치를 추적하고 지오펜스 알림을 받을 수 있습니다.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
            }
        } header: {
            Text("권한")
        } footer: {
            Text("'항상 허용'을 선택하면 앱이 종료되어도 지오펜스 알림을 받을 수 있습니다.")
        }
    }
    
    /// 권한 상태에 따른 색상
    private var permissionStatusColor: Color {
        switch locationManager.permissionStatus {
        case .authorizedAlways:
            return .green
        case .authorizedWhenInUse:
            return .yellow
        case .denied, .restricted:
            return .red
        case .notDetermined:
            return .gray
        }
    }
    
    // MARK: - 정확도 섹션
    
    private var accuracySection: some View {
        Section {
            Picker("위치 정확도", selection: $locationManager.settings.accuracyLevel) {
                ForEach(LocationSettings.AccuracyLevel.allCases, id: \.self) { level in
                    Text(level.rawValue).tag(level)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("최소 이동 거리")
                    Spacer()
                    Text("\(Int(locationManager.settings.distanceFilter))m")
                        .foregroundColor(.secondary)
                }
                
                Slider(
                    value: $locationManager.settings.distanceFilter,
                    in: 1...100,
                    step: 1
                )
            }
        } header: {
            Text("위치 정확도")
        } footer: {
            Text("높은 정확도는 더 많은 배터리를 소모합니다. 최소 이동 거리는 위치 업데이트 간격을 조절합니다.")
        }
    }
    
    // MARK: - 추적 설정 섹션
    
    private var trackingSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("추적 간격")
                    Spacer()
                    Text("\(Int(locationManager.settings.trackingInterval))초")
                        .foregroundColor(.secondary)
                }
                
                Slider(
                    value: $locationManager.settings.trackingInterval,
                    in: 1...60,
                    step: 1
                )
            }
        } header: {
            Text("추적 설정")
        } footer: {
            Text("경로 기록 시 위치 포인트를 저장하는 최소 간격입니다.")
        }
    }
    
    // MARK: - 백그라운드 설정 섹션
    
    private var backgroundSection: some View {
        Section {
            Toggle("백그라운드 업데이트", isOn: $locationManager.settings.backgroundUpdates)
            
            Toggle("백그라운드 인디케이터", isOn: $locationManager.settings.showsBackgroundIndicator)
                .disabled(!locationManager.settings.backgroundUpdates)
            
            Toggle("자동 일시정지", isOn: $locationManager.settings.pausesAutomatically)
        } header: {
            Text("백그라운드")
        } footer: {
            Text("백그라운드 인디케이터는 상태 바에 파란색 알약 모양으로 표시됩니다. 자동 일시정지는 이동이 없을 때 배터리를 절약합니다.")
        }
    }
    
    // MARK: - 데이터 관리 섹션
    
    private var dataSection: some View {
        Section {
            // 저장된 데이터 요약
            HStack {
                Text("저장된 경로")
                Spacer()
                Text("\(locationManager.savedTracks.count)개")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("등록된 지오펜스")
                Spacer()
                Text("\(geofenceManager.geofences.count)개")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("지오펜스 이벤트")
                Spacer()
                Text("\(geofenceManager.events.count)개")
                    .foregroundColor(.secondary)
            }
            
            // 데이터 삭제 버튼
            Button(role: .destructive) {
                showDeleteDataConfirmation = true
            } label: {
                HStack {
                    Text("모든 데이터 삭제")
                    Spacer()
                    Image(systemName: "trash")
                }
            }
        } header: {
            Text("데이터 관리")
        }
    }
    
    // MARK: - 앱 정보 섹션
    
    private var aboutSection: some View {
        Section {
            HStack {
                Text("앱 버전")
                Spacer()
                Text(Bundle.main.appVersionString)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("빌드 번호")
                Spacer()
                Text(Bundle.main.buildNumberString)
                    .foregroundColor(.secondary)
            }
            
            NavigationLink {
                PrivacyInfoView()
            } label: {
                Text("개인정보 처리방침")
            }
            
            NavigationLink {
                LicenseInfoView()
            } label: {
                Text("오픈소스 라이선스")
            }
        } header: {
            Text("정보")
        }
    }
    
    // MARK: - Methods
    
    /// 모든 데이터 삭제
    private func deleteAllData() {
        locationManager.deleteAllTracks()
        geofenceManager.removeAllGeofences()
        geofenceManager.clearEvents()
    }
}

// MARK: - Bundle 확장

extension Bundle {
    /// 앱 버전 문자열
    var appVersionString: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    /// 빌드 번호 문자열
    var buildNumberString: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

// MARK: - 개인정보 처리방침 뷰

struct PrivacyInfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("개인정보 처리방침")
                    .font(.title)
                    .fontWeight(.bold)
                
                Group {
                    Text("1. 수집하는 정보")
                        .font(.headline)
                    Text("이 앱은 위치 정보를 수집합니다. 수집된 정보는 기기 내에서만 저장되며 외부 서버로 전송되지 않습니다.")
                    
                    Text("2. 정보의 사용 목적")
                        .font(.headline)
                    Text("• 경로 기록 및 시각화\n• 지오펜스 알림 제공\n• 이동 통계 계산")
                    
                    Text("3. 정보의 보관")
                        .font(.headline)
                    Text("모든 데이터는 기기 내 로컬 저장소에만 보관됩니다. 앱을 삭제하면 모든 데이터가 함께 삭제됩니다.")
                    
                    Text("4. 데이터 삭제")
                        .font(.headline)
                    Text("설정 > 데이터 관리에서 언제든지 저장된 데이터를 삭제할 수 있습니다.")
                }
            }
            .padding()
        }
        .navigationTitle("개인정보 처리방침")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 라이선스 정보 뷰

struct LicenseInfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("오픈소스 라이선스")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("이 앱은 Apple의 SwiftUI, MapKit, CoreLocation 프레임워크를 사용합니다.")
                
                Divider()
                
                Text("MIT License")
                    .font(.headline)
                
                Text("""
                    Copyright (c) 2024
                    
                    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
                    
                    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
                    
                    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
                    """)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("라이선스")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 미리보기

#Preview {
    SettingsView()
        .environmentObject(LocationManager.shared)
        .environmentObject(GeofenceManager.shared)
}
