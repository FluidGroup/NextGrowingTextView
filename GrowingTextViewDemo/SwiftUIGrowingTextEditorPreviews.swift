import NextGrowingTextViewSwiftUI
import SwiftUI

/// A full-screen catalog that shows the main SwiftUI growing editor behaviors
/// in one scrollable surface.
struct SwiftUIGrowingTextEditorOverviewPreview: View {

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        SwiftUIGrowingTextEditorPreviewHeader()
        SwiftUIGrowingTextEditorReadmeSection()
        SwiftUIGrowingTextEditorMessagesShowcaseSection()
        SwiftUIGrowingTextEditorSizingSection()
        SwiftUIGrowingTextEditorComposerSection()
      }
      .padding(20)
    }
    .background(Color(.systemGroupedBackground))
  }
}

/// Header copy for the SwiftUI preview catalog.
private struct SwiftUIGrowingTextEditorPreviewHeader: View {

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("SwiftUI")
        .font(.largeTitle.bold())

      Text("GrowingTextEditor previews built from the SwiftUI package product.")
        .font(.body)
        .foregroundStyle(.secondary)
    }
  }
}

/// A README-shaped example that keeps the public API sample easy to verify.
private struct SwiftUIGrowingTextEditorReadmeSection: View {

  @State private var text = """
  This editor starts at one line, grows as content wraps, and scrolls after six lines.
  """

  var body: some View {
    GrowingTextEditorDemoCard(
      title: "README configuration",
      description: "Matches the SwiftUI usage snippet: min 1, max 6, custom padding, and line spacing."
    ) {
      GrowingTextEditor(
        text: $text,
        placeholder: "Write something...",
        configuration: GrowingTextEditorConfiguration(
          minLines: 1,
          maxLines: 6,
          horizontalPadding: 8,
          verticalPadding: 4,
          lineSpacing: 3
        ),
        font: .body
      )
      .background(.yellow.opacity(0.18), in: RoundedRectangle(cornerRadius: 12))
    }
  }
}

/// A polished, Messages-inspired preview that shows the editor inside a chat
/// composer instead of a neutral component card.
private struct SwiftUIGrowingTextEditorMessagesShowcaseSection: View {

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      VStack(alignment: .leading, spacing: 4) {
        Text("Messages-style composer")
          .font(.title2.bold())

        Text("A richer preview for seeing the growing editor in a familiar chat surface.")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }

      SwiftUIGrowingTextEditorMessagesPreview()
        .frame(height: 640)
    }
  }
}

/// A Messages-inspired screen that highlights `GrowingTextEditor` in context.
struct SwiftUIGrowingTextEditorMessagesPreview: View {

  @State private var draft = """
  This composer uses GrowingTextEditor, so the input expands as the message gets longer.
  """

  var body: some View {
    ZStack {
      SwiftUIGrowingTextEditorMessagesBackdrop()

      VStack(spacing: 0) {
        SwiftUIGrowingTextEditorMessagesHeader(
          contactName: "Aoi",
          status: "iMessage"
        )

        SwiftUIGrowingTextEditorMessagesTranscript(
          messages: SwiftUIGrowingTextEditorMessage.samples
        )

        SwiftUIGrowingTextEditorMessagesComposer(text: $draft)
      }
      .background(.regularMaterial)
    }
    .background(Color(.systemGroupedBackground))
  }
}

/// Atmospheric background used behind the Messages-style phone surface.
private struct SwiftUIGrowingTextEditorMessagesBackdrop: View {

  var body: some View {
    LinearGradient(
      colors: [
        Color(red: 0.78, green: 0.90, blue: 1.00),
        Color(red: 0.95, green: 0.97, blue: 1.00),
        Color(red: 0.95, green: 0.92, blue: 0.86),
      ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
    .overlay(alignment: .topTrailing) {
      Circle()
        .fill(.blue.opacity(0.16))
        .frame(width: 220, height: 220)
        .blur(radius: 18)
        .offset(x: 80, y: -80)
    }
    .overlay(alignment: .bottomLeading) {
      Circle()
        .fill(.mint.opacity(0.18))
        .frame(width: 180, height: 180)
        .blur(radius: 20)
        .offset(x: -70, y: 70)
    }
  }
}

/// Header chrome for the Messages-style preview.
private struct SwiftUIGrowingTextEditorMessagesHeader: View {

  let contactName: String
  let status: String

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: "chevron.left")
        .font(.headline.weight(.semibold))
        .foregroundStyle(.blue)

      Spacer()

      VStack(spacing: 5) {
        ZStack {
          Circle()
            .fill(
              LinearGradient(
                colors: [.cyan, .blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )

          Text(String(contactName.prefix(1)))
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
        }
        .frame(width: 42, height: 42)

        VStack(spacing: 1) {
          Text(contactName)
            .font(.caption.weight(.semibold))

          Text(status)
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
      }

      Spacer()

      Image(systemName: "video")
        .font(.headline.weight(.semibold))
        .foregroundStyle(.blue)
    }
    .padding(.horizontal, 16)
    .padding(.top, 14)
    .padding(.bottom, 10)
    .background(.thinMaterial)
  }
}

/// Scrollable transcript for the Messages-style preview.
private struct SwiftUIGrowingTextEditorMessagesTranscript: View {

  let messages: [SwiftUIGrowingTextEditorMessage]

  var body: some View {
    ScrollView {
      VStack(spacing: 10) {
        Text("Today 14:32")
          .font(.caption2.weight(.medium))
          .foregroundStyle(.secondary)
          .padding(.vertical, 8)

        ForEach(messages) { message in
          SwiftUIGrowingTextEditorMessageBubble(message: message)
        }
      }
      .padding(.horizontal, 14)
      .padding(.bottom, 18)
    }
    .scrollIndicators(.hidden)
  }
}

/// One transcript bubble in the Messages-style preview.
private struct SwiftUIGrowingTextEditorMessageBubble: View {

  let message: SwiftUIGrowingTextEditorMessage

  var body: some View {
    HStack(alignment: .bottom, spacing: 6) {
      if message.isOutgoing {
        Spacer(minLength: 42)
      }

      Text(message.text)
        .font(.body)
        .foregroundStyle(message.isOutgoing ? .white : .primary)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(messageBackground, in: bubbleShape)
        .shadow(color: .black.opacity(message.isOutgoing ? 0.14 : 0.06), radius: 4, x: 0, y: 2)

      if message.isOutgoing == false {
        Spacer(minLength: 42)
      }
    }
    .frame(maxWidth: .infinity, alignment: message.isOutgoing ? .trailing : .leading)
  }

  private var messageBackground: some ShapeStyle {
    if message.isOutgoing {
      return AnyShapeStyle(
        LinearGradient(
          colors: [.blue, Color(red: 0.10, green: 0.45, blue: 1.00)],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )
    } else {
      return AnyShapeStyle(.white.opacity(0.92))
    }
  }

  private var bubbleShape: UnevenRoundedRectangle {
    if message.isOutgoing {
      UnevenRoundedRectangle(
        topLeadingRadius: 20,
        bottomLeadingRadius: 20,
        bottomTrailingRadius: 6,
        topTrailingRadius: 20,
        style: .continuous
      )
    } else {
      UnevenRoundedRectangle(
        topLeadingRadius: 20,
        bottomLeadingRadius: 6,
        bottomTrailingRadius: 20,
        topTrailingRadius: 20,
        style: .continuous
      )
    }
  }
}

/// Composer bar for the Messages-style preview.
private struct SwiftUIGrowingTextEditorMessagesComposer: View {

  @Binding var text: String

  var body: some View {
    HStack(alignment: .bottom, spacing: 9) {
      Button {
        text = SwiftUIGrowingTextEditorMessagesText.cameraMessage
      } label: {
        Image(systemName: "camera.fill")
          .font(.headline)
          .foregroundStyle(.secondary)
          .frame(width: 34, height: 34)
          .background(.thinMaterial, in: Circle())
      }
      .accessibilityLabel("Insert camera message")

      GrowingTextEditor(
        text: $text,
        placeholder: "iMessage",
        configuration: GrowingTextEditorConfiguration(
          minLines: 1,
          maxLines: 5,
          horizontalPadding: 9,
          verticalPadding: 5,
          lineSpacing: 2
        ),
        font: .body
      )
      .background(.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
          .stroke(.black.opacity(0.08), lineWidth: 1)
      }

      Button {
        text = ""
      } label: {
        Image(systemName: "arrow.up.circle.fill")
          .font(.system(size: 32, weight: .semibold))
          .foregroundStyle(text.isEmpty ? Color.secondary.opacity(0.45) : Color.blue)
      }
      .accessibilityLabel("Send")
      .disabled(text.isEmpty)
    }
    .padding(.horizontal, 12)
    .padding(.top, 10)
    .padding(.bottom, 14)
    .background(.ultraThinMaterial)
  }
}

/// Message data rendered by the Messages-style preview.
private struct SwiftUIGrowingTextEditorMessage: Identifiable, Equatable {

  let id: Int
  let text: String
  let isOutgoing: Bool

  static let samples: [SwiftUIGrowingTextEditorMessage] = [
    .init(id: 1, text: "Could this fit into a Messages-style composer?", isOutgoing: false),
    .init(id: 2, text: "Yes. The editor grows without the surrounding bar jumping around.", isOutgoing: true),
    .init(id: 3, text: "Nice. It should still feel light when the text wraps.", isOutgoing: false),
    .init(id: 4, text: "Try editing the draft below and watch it expand up to five lines.", isOutgoing: true),
  ]
}

/// Shared copy used by the Messages-style preview controls.
private enum SwiftUIGrowingTextEditorMessagesText {

  static let cameraMessage = "Photo attached. Adding a little more text to show the growing composer wrapping across multiple lines."
}

/// A pair of SwiftUI sizing previews that mirror the old demo's width cases.
private struct SwiftUIGrowingTextEditorSizingSection: View {

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Sizing")
        .font(.title2.bold())

      SwiftUIGrowingTextEditorSizingPreview(layout: .flexibleWidth)
      SwiftUIGrowingTextEditorSizingPreview(layout: .fixedWidth)
    }
  }
}

/// Width behavior for SwiftUI growing editor previews.
private enum SwiftUIGrowingTextEditorPreviewLayout {

  /// The editor keeps a narrow ideal width and expands as the text needs more
  /// horizontal space.
  case flexibleWidth

  /// The editor fills the available horizontal space before growing vertically.
  case fixedWidth

  var title: LocalizedStringResource {
    switch self {
    case .flexibleWidth:
      "Flexible width"
    case .fixedWidth:
      "Fixed width"
    }
  }

  var description: LocalizedStringResource {
    switch self {
    case .flexibleWidth:
      "Starts compact and centered so wrapped text drives vertical growth."
    case .fixedWidth:
      "Uses the full container width before growing vertically."
    }
  }
}

/// An interactive SwiftUI editor preview with configurable line limits.
private struct SwiftUIGrowingTextEditorSizingPreview: View {

  let layout: SwiftUIGrowingTextEditorPreviewLayout

  @State private var text = ""
  @State private var minLines = 1
  @State private var maxLines = 10
  @State private var usesLongPlaceholder = false

  var body: some View {
    GrowingTextEditorDemoCard(
      title: layout.title,
      description: layout.description
    ) {
      VStack(alignment: .leading, spacing: 14) {
        editor
        GrowingTextEditorControlPanel(
          text: $text,
          minLines: $minLines,
          maxLines: $maxLines,
          usesLongPlaceholder: $usesLongPlaceholder
        )
      }
    }
  }

  private var editor: some View {
    growingEditor
      .font(.system(size: 20, weight: .bold))
      .frame(maxWidth: maxWidth, alignment: .center)
      .background(.yellow.opacity(0.2), in: RoundedRectangle(cornerRadius: 14))
      .frame(maxWidth: .infinity, alignment: .center)
  }

  private var growingEditor: some View {
    GrowingTextEditor(
      text: $text,
      placeholder: placeholder,
      configuration: GrowingTextEditorConfiguration(
        minLines: minLines,
        maxLines: maxLines,
        horizontalPadding: 8,
        verticalPadding: 6,
        lineSpacing: 2
      ),
      font: .system(size: 20, weight: .bold)
    )
  }

  private var placeholder: LocalizedStringKey {
    if usesLongPlaceholder {
      return "Placeholder, Placeholder, Placeholder, "
    } else {
      return "Placeholder"
    }
  }

  private var maxWidth: CGFloat? {
    switch layout {
    case .flexibleWidth:
      220
    case .fixedWidth:
      .infinity
    }
  }
}

/// Buttons and steppers that mutate a SwiftUI sizing preview.
private struct GrowingTextEditorControlPanel: View {

  @Binding var text: String
  @Binding var minLines: Int
  @Binding var maxLines: Int
  @Binding var usesLongPlaceholder: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      ViewThatFits {
        HStack(spacing: 8) {
          textButtons
          placeholderButton
        }

        VStack(alignment: .leading, spacing: 8) {
          textButtons
          placeholderButton
        }
      }

      Stepper("Min lines: \(minLines)", value: $minLines, in: 1...5)
      Stepper("Max lines: \(maxLines)", value: $maxLines, in: minLines...10)
    }
    .onChange(of: minLines) { _, newValue in
      maxLines = Swift.max(maxLines, newValue)
    }
    .buttonStyle(.bordered)
  }

  private var textButtons: some View {
    HStack(spacing: 8) {
      Button("Set text") {
        text = GrowingTextEditorDemoText.longMessage
      }

      Button("Clear text") {
        text = ""
      }
    }
  }

  private var placeholderButton: some View {
    Button(usesLongPlaceholder ? "Short placeholder" : "Long placeholder") {
      usesLongPlaceholder.toggle()
    }
  }
}

/// A practical composer-style example that exercises the max-line cap.
private struct SwiftUIGrowingTextEditorComposerSection: View {

  @State private var message = ""

  var body: some View {
    GrowingTextEditorDemoCard(
      title: "Composer",
      description: "A chat-style input that grows until five lines, then lets the editor scroll."
    ) {
      HStack(alignment: .bottom, spacing: 10) {
        GrowingTextEditor(
          text: $message,
          placeholder: "Message",
          configuration: GrowingTextEditorConfiguration(
            minLines: 1,
            maxLines: 5,
            horizontalPadding: 10,
            verticalPadding: 6,
            lineSpacing: 2
          ),
          font: .body
        )
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 18))

        Button {
          message = ""
        } label: {
          Image(systemName: "arrow.up")
            .font(.headline)
            .foregroundStyle(.white)
            .frame(width: 34, height: 34)
            .background(.blue, in: Circle())
        }
        .accessibilityLabel("Send")
        .disabled(message.isEmpty)
      }
    }
  }
}

/// A reusable visual container for preview cases.
private struct GrowingTextEditorDemoCard<Content: View>: View {

  let title: LocalizedStringResource
  let description: LocalizedStringResource
  let content: Content

  init(
    title: LocalizedStringResource,
    description: LocalizedStringResource,
    @ViewBuilder content: () -> Content
  ) {
    self.title = title
    self.description = description
    self.content = content()
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      GrowingTextEditorDemoCardHeader(title: title, description: description)
      content
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(.background, in: RoundedRectangle(cornerRadius: 20))
  }
}

/// Title and helper text for a preview card.
private struct GrowingTextEditorDemoCardHeader: View {

  let title: LocalizedStringResource
  let description: LocalizedStringResource

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .font(.headline)

      Text(description)
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
  }
}

/// Shared sample strings used by the interactive previews.
private enum GrowingTextEditorDemoText {

  static let longMessage = """
  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec posuere lectus sed arcu facilisis, at bibendum orci interdum. Integer non luctus lorem. Try editing this text and watch the container grow until it reaches the configured maximum line count.
  """
}

#Preview("SwiftUI / Overview") {
  SwiftUIGrowingTextEditorOverviewPreview()
}

#Preview("SwiftUI / README configuration") {
  ScrollView {
    SwiftUIGrowingTextEditorReadmeSection()
      .padding(20)
  }
  .background(Color(.systemGroupedBackground))
}

#Preview("SwiftUI / Messages style") {
  SwiftUIGrowingTextEditorMessagesPreview()
}

#Preview("SwiftUI / Flexible width") {
  ScrollView {
    SwiftUIGrowingTextEditorSizingPreview(layout: .flexibleWidth)
      .padding(20)
  }
  .background(Color(.systemGroupedBackground))
}

#Preview("SwiftUI / Fixed width") {
  ScrollView {
    SwiftUIGrowingTextEditorSizingPreview(layout: .fixedWidth)
      .padding(20)
  }
  .background(Color(.systemGroupedBackground))
}

#Preview("SwiftUI / Composer") {
  ScrollView {
    SwiftUIGrowingTextEditorComposerSection()
      .padding(20)
  }
  .background(Color(.systemGroupedBackground))
}
