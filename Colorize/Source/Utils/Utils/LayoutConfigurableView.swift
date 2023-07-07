protocol LayoutConfigurableView {
    func configureView()
    func configureViewProperties()
    func configureSubviews()
    func configureLayout()
}

extension LayoutConfigurableView {
    func configureView() {
        configureViewProperties()
        configureSubviews()
        configureLayout()
    }

    func configureViewProperties() {}
    func configureSubviews() {}
    func configureLayout() {}
}

extension LayoutConfigurableView where Self: BindingConfigurableView {
    func configureView() {
        configureViewProperties()
        configureSubviews()
        configureLayout()
        configureBinding()
    }
}
