import WidgetKit
import SwiftUI

@main
struct HIGPracticeWidgetBundle: WidgetBundle {
    var body: some Widget {
        WeatherWidget()
        DeliveryTrackerLiveActivity()
    }
}
