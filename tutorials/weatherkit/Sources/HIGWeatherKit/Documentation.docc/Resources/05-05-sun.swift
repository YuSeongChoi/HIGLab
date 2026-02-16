import WeatherKit

// 일출/일몰 정보

func exploreSunData(_ day: DayWeather) {
    let sun = day.sun
    
    // 일출 시간 (극지방에서는 nil일 수 있음)
    if let sunrise = sun.sunrise {
        print("일출: \(sunrise.formatted(date: .omitted, time: .shortened))")
    } else {
        print("일출 없음 (백야/극야)")
    }
    
    // 일몰 시간
    if let sunset = sun.sunset {
        print("일몰: \(sunset.formatted(date: .omitted, time: .shortened))")
    }
    
    // 시민박명 (Civil Twilight)
    // 해가 지평선 아래 6도일 때까지, 야외 활동 가능한 밝기
    if let dawn = sun.civilDawn {
        print("시민박명 시작: \(dawn.formatted(date: .omitted, time: .shortened))")
    }
    
    if let dusk = sun.civilDusk {
        print("시민박명 종료: \(dusk.formatted(date: .omitted, time: .shortened))")
    }
    
    // 낮 시간 계산
    if let sunrise = sun.sunrise, let sunset = sun.sunset {
        let dayLength = sunset.timeIntervalSince(sunrise)
        let hours = Int(dayLength / 3600)
        let minutes = Int((dayLength.truncatingRemainder(dividingBy: 3600)) / 60)
        print("낮 길이: \(hours)시간 \(minutes)분")
    }
}
