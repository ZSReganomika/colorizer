protocol BindingConfigurableView {
    func configureBinding()
    func bindInput()
    func bindOutput()
}

extension BindingConfigurableView {
    func configureBinding() {
        bindInput()
        bindOutput()
    }

    func bindInput() {}
    func bindOutput() {}
}
