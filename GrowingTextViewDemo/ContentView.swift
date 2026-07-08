import SwiftUI
import StorybookKit

/// Root view for the demo application.
///
/// `Storybook` discovers `#Preview` declarations in this target at runtime, so
/// each demo remains usable both from Xcode Previews and from the app itself.
struct ContentView: View {
  var body: some View {
    Storybook()
  }
}
