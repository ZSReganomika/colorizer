protocol SelfConfiguringCell {
    static var reuseIdentifier: String { get }
    func configure(with intValue: Int)
}
