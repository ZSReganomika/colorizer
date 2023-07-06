public protocol LayoutConfigurableView {
    func configureView()
    func configureViewProperties()
    func configureSubviews()
    func configureLayout()
}

public extension LayoutConfigurableView {
    func configureView() {
        self.configureViewProperties()
        self.configureSubviews()
        self.configureLayout()
    }

    func configureViewProperties() {}
    func configureSubviews() {}
    func configureLayout() {}
}

