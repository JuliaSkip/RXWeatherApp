//
//  ViewController.swift
//  RXSkip03
//
//  Created by Скіп Юлія Ярославівна on 09.02.2026.
//
import UIKit
import RxSwift
import RxCocoa
import RxDataSources


class ViewController: UIViewController {
    
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var placeholderImageView: UIImageView!
    
    private let bag = DisposeBag()
    private let viewModel = WeatherViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInputField()
        setupBindings()
        tableView.rx.setDelegate(self).disposed(by: bag)
    }
    
    private func setupInputField() {
        inputField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        inputField.leftViewMode = .always
        inputField.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        inputField.attributedPlaceholder = NSAttributedString(
            string: "Введіть місто для пошуку...",
            attributes: [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 14)
            ]
        )
    }
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    private func setupBindings() {
        inputField.rx.text
            .orEmpty
            .bind(to: viewModel.cityText)
            .disposed(by: bag)
        
        viewModel.sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        viewModel.isPlaceholderHidden
            .bind(to: placeholderImageView.rx.isHidden)
            .disposed(by: bag)
    }

    
    private lazy var dataSource =
    RxTableViewSectionedReloadDataSource<WeatherSection>(
        configureCell: { _, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell( withIdentifier: "WeatherCell", for: indexPath ) as! WeatherCell
            cell.config(with: item)
            return cell
        },
        titleForHeaderInSection: { $0.sectionModels[$1].header }
    )
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = .label
            header.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        }
    }
}
