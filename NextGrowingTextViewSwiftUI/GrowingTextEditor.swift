import SwiftUI

/// Layout rules for a SwiftUI text editor that grows with its text content.
///
/// The editor stays at `minLines` while short or empty, expands as text wraps,
/// and caps at `maxLines` when provided. Once capped, SwiftUI's `TextEditor`
/// owns the inner scrolling behavior.
@available(iOS 16.0, *)
public struct GrowingTextEditorConfiguration: Sendable, Equatable {

  /// The smallest number of visual lines the editor should reserve.
  public var minLines: Int

  /// The largest number of visual lines before the editor starts scrolling.
  ///
  /// Use `nil` for an uncapped editor that keeps expanding with its content.
  public var maxLines: Int?

  /// Horizontal space applied around both the visible editor and the hidden
  /// measuring editor.
  public var horizontalPadding: CGFloat

  /// Vertical space applied around both the visible editor and the hidden
  /// measuring editor.
  public var verticalPadding: CGFloat

  /// Extra spacing inserted between rendered text lines.
  public var lineSpacing: CGFloat

  /// Creates layout rules for a growing SwiftUI text editor.
  public init(
    minLines: Int = 1,
    maxLines: Int? = nil,
    horizontalPadding: CGFloat = 5,
    verticalPadding: CGFloat = 8,
    lineSpacing: CGFloat = 0
  ) {
    let resolvedMinLines = Swift.max(1, minLines)
    self.minLines = resolvedMinLines
    self.maxLines = maxLines.map { Swift.max(resolvedMinLines, $0) }
    self.horizontalPadding = horizontalPadding
    self.verticalPadding = verticalPadding
    self.lineSpacing = lineSpacing
  }

  var contentInsets: EdgeInsets {
    EdgeInsets(
      top: verticalPadding,
      leading: horizontalPadding,
      bottom: verticalPadding,
      trailing: horizontalPadding
    )
  }
}

/// A pure SwiftUI growing text input built on top of `TextEditor`.
///
/// The implementation measures a hidden, non-scrolling `TextEditor` with the
/// same font, line spacing, and padding as the visible editor, then applies the
/// measured height back to the visible `TextEditor`. It intentionally does not
/// bridge to `UITextView`, which means UIKit-only hooks such as content offset
/// control and flashing scroll indicators are outside this component's contract.
@available(iOS 16.0, *)
public struct GrowingTextEditor<Placeholder: View>: View {

  @Binding private var text: String

  @Environment(\.font) private var environmentFont
  @State private var measurements = GrowingTextEditorMeasurements()

  private let configuration: GrowingTextEditorConfiguration
  private let explicitFont: Font?
  private let placeholder: Placeholder

  /// Creates a growing text editor with custom placeholder content.
  public init(
    text: Binding<String>,
    configuration: GrowingTextEditorConfiguration = GrowingTextEditorConfiguration(),
    font: Font? = nil,
    @ViewBuilder placeholder: () -> Placeholder
  ) {
    self._text = text
    self.configuration = configuration
    self.explicitFont = font
    self.placeholder = placeholder()
  }

  public var body: some View {
    editor
      .frame(height: resolvedHeight)
      .overlay(alignment: .topLeading) {
        if text.isEmpty {
          placeholder
            .foregroundStyle(.secondary)
            .padding(placeholderInsets)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
      }
      .background(alignment: .topLeading) {
        measurementLayer
      }
      .onPreferenceChange(GrowingTextEditorHeightPreferenceKey.self) { values in
        measurements.update(with: values)
      }
  }

  @ViewBuilder
  private var editor: some View {
    TextEditor(text: $text)
      .font(resolvedFont)
      .lineSpacing(configuration.lineSpacing)
      .scrollContentBackground(.hidden)
      .padding(configuration.contentInsets)
  }

  private var measurementLayer: some View {
    ZStack(alignment: .topLeading) {
      measurementEditor(
        GrowingTextEditorMeasurementText.content(for: text),
        role: .content
      )
      measurementEditor(
        GrowingTextEditorMeasurementText.lines(configuration.minLines),
        role: .minimum
      )
      if let maxLines = configuration.maxLines {
        measurementEditor(
          GrowingTextEditorMeasurementText.lines(maxLines),
          role: .maximum
        )
      }
    }
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }

  private func measurementEditor(
    _ value: String,
    role: GrowingTextEditorMeasurementRole
  ) -> some View {
    TextEditor(text: .constant(value))
      .font(resolvedFont)
      .lineSpacing(configuration.lineSpacing)
      .scrollContentBackground(.hidden)
      .scrollDisabled(true)
      .padding(configuration.contentInsets)
      .frame(maxWidth: .infinity, alignment: .topLeading)
      .fixedSize(horizontal: false, vertical: true)
      .hidden()
      .readGrowingTextEditorHeight(for: role)
  }

  private var resolvedFont: Font {
    explicitFont ?? environmentFont ?? .body
  }

  private var placeholderInsets: EdgeInsets {
    EdgeInsets(
      top: configuration.verticalPadding + GrowingTextEditorTextEditorInset.top,
      leading: configuration.horizontalPadding + GrowingTextEditorTextEditorInset.leading,
      bottom: configuration.verticalPadding + GrowingTextEditorTextEditorInset.bottom,
      trailing: configuration.horizontalPadding + GrowingTextEditorTextEditorInset.trailing
    )
  }

  private var resolvedHeight: CGFloat {
    let minimum = measurements.minimum ?? measurements.content ?? 1
    let content = Swift.max(measurements.content ?? minimum, minimum)

    if let maximum = measurements.maximum {
      return Swift.min(content, Swift.max(maximum, minimum))
    } else {
      return content
    }
  }
}

@available(iOS 16.0, *)
public extension GrowingTextEditor where Placeholder == EmptyView {

  /// Creates an editor without placeholder content.
  init(
    text: Binding<String>,
    configuration: GrowingTextEditorConfiguration = GrowingTextEditorConfiguration(),
    font: Font? = nil
  ) {
    self._text = text
    self.configuration = configuration
    self.explicitFont = font
    self.placeholder = EmptyView()
  }
}

@available(iOS 16.0, *)
public extension GrowingTextEditor where Placeholder == Text {

  /// Creates an editor with a localizable text placeholder.
  init(
    text: Binding<String>,
    placeholder: LocalizedStringKey,
    configuration: GrowingTextEditorConfiguration = GrowingTextEditorConfiguration(),
    font: Font? = nil
  ) {
    self._text = text
    self.configuration = configuration
    self.explicitFont = font
    self.placeholder = Text(placeholder)
  }
}

/// A `TextView`-named alias for the SwiftUI growing editor.
@available(iOS 16.0, *)
public typealias GrowingTextView<Placeholder: View> = GrowingTextEditor<Placeholder>

@available(iOS 16.0, *)
private struct GrowingTextEditorMeasurements: Equatable {
  var content: CGFloat?
  var minimum: CGFloat?
  var maximum: CGFloat?

  mutating func update(with values: [GrowingTextEditorMeasurementRole: CGFloat]) {
    content = values[.content] ?? content
    minimum = values[.minimum] ?? minimum
    maximum = values[.maximum] ?? maximum
  }
}

@available(iOS 16.0, *)
private enum GrowingTextEditorMeasurementRole: Hashable {
  case content
  case minimum
  case maximum
}

@available(iOS 16.0, *)
private enum GrowingTextEditorTextEditorInset {
  #if os(macOS)
    /// AppKit's editor has no vertical text-container inset and uses five-point
    /// line-fragment padding on each horizontal edge.
    static let top: CGFloat = 0
    static let leading: CGFloat = 5
    static let bottom: CGFloat = 0
    static let trailing: CGFloat = 5
  #else
    /// Approximate default inset SwiftUI's UIKit-backed `TextEditor` keeps
    /// between its outer bounds and first rendered glyph.
    static let top: CGFloat = 8
    static let leading: CGFloat = 4
    static let bottom: CGFloat = 8
    static let trailing: CGFloat = 4
  #endif
}

@available(iOS 16.0, *)
private enum GrowingTextEditorMeasurementText {

  static func content(for text: String) -> String {
    let value = text.isEmpty ? " " : text

    if value.hasSuffix("\n") {
      return value + " "
    } else {
      return value
    }
  }

  static func lines(_ count: Int) -> String {
    Array(repeating: " ", count: Swift.max(1, count)).joined(separator: "\n")
  }
}

@available(iOS 16.0, *)
private struct GrowingTextEditorHeightPreferenceKey: PreferenceKey {
  static let defaultValue: [GrowingTextEditorMeasurementRole: CGFloat] = [:]

  static func reduce(
    value: inout [GrowingTextEditorMeasurementRole: CGFloat],
    nextValue: () -> [GrowingTextEditorMeasurementRole: CGFloat]
  ) {
    value.merge(nextValue(), uniquingKeysWith: { _, new in new })
  }
}

@available(iOS 16.0, *)
private extension View {

  func readGrowingTextEditorHeight(for role: GrowingTextEditorMeasurementRole) -> some View {
    background {
      GeometryReader { proxy in
        Color.clear.preference(
          key: GrowingTextEditorHeightPreferenceKey.self,
          value: [role: proxy.size.height]
        )
      }
    }
  }
}
