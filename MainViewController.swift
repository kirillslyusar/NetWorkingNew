//
//  MainViewController.swift
//  Networking
//
//  Created by Alexey Efimov on 21/08/2019.
//  Copyright © 2019 Alexey Efimov. All rights reserved.
//

import UIKit



enum UserAction: CaseIterable {
    case showImage
    case fetchCourse
    case fetchCourses
    case aboutSwiftBook
    case aboutSwiftBook2
    case showCourses
    case postRequestWithDict
    case postRequestWithModel
    
    var title: String {
        switch self {
        case .showImage:
            return "Show Image"
        case .fetchCourse:
            return "Fetch Course"
        case .fetchCourses:
            return "Fetch Courses"
        case .aboutSwiftBook:
            return "About SwiftBook"
        case .aboutSwiftBook2:
            return "About SwiftBook 2"
        case .showCourses:
            return "Show Courses"
        case .postRequestWithDict:
            return "POST RQST with Dict"
        case .postRequestWithModel:
            return "POST RQST with Model"
        }
    }
}

enum Alert {
    case success
    case failed
    
    var title: String {
        switch self {
        case .success:
            return "Success"
        case .failed:
            return "Failed"
        }
    }
    
    var message: String {
        switch self {
        case .success:
            return "You can see the results in the Debug aria"
        case .failed:
            return "You can see error in the Debug aria"
        }
    }
}

final class MainViewController: UICollectionViewController {
    
    private let userActions = UserAction.allCases
    private let networkManager = NetworkManager.shared

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        userActions.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userAction", for: indexPath) as! UserActionCell
    
        cell.userActionLabel.text = userActions[indexPath.item].title
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let userAction = userActions[indexPath.item]
        
        switch userAction {
        case .showImage: performSegue(withIdentifier: "showImage", sender: nil)
        case .fetchCourse: fetchCourse()
        case .fetchCourses: fetchCourses()
        case .aboutSwiftBook: fetchInfoAboutUs()
        case .aboutSwiftBook2: fetchInfoAboutUsWithEmptyFields()
        case .showCourses: performSegue(withIdentifier: "showCourses", sender: nil)
        case .postRequestWithDict: postRequestWithDict()
        case .postRequestWithModel: postRequestWithModel()
        }
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCourses" {
            guard let coursesVC = segue.destination as? CoursesViewController else { return }
            coursesVC.fetchCourses()
        }
    }
 

    // MARK: - Private Methods
    private func showAlert(withStatus status: Alert) {
        let alert = UIAlertController(title: status.title, message: status.message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        DispatchQueue.main.async { [unowned self] in
            present(alert, animated: true)
        }
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: UIScreen.main.bounds.width - 48, height: 100)
    }
}

// MARK: - Networking
extension MainViewController {
    private func fetchCourse() {
        networkManager.fetch(Course.self, from: Link.courseURL.url) { [weak self] result in
            switch result {
            case .success(let course):
                print(course)
                self?.showAlert(withStatus: .success)
            case .failure(let error):
                print(error)
                self?.showAlert(withStatus: .failed)
            }
        }
    }
    
    private func fetchCourses() {
        networkManager.fetch([Course].self, from: Link.coursesURL.url) { [weak self] result in
            switch result {
            case .success(let courses):
                print(courses)
                self?.showAlert(withStatus: .success)
            case .failure(let error):
                print(error)
                self?.showAlert(withStatus: .failed)
            }
        }
    }
    
    private func fetchInfoAboutUs() {
        networkManager.fetch(SwiftbookInfo.self, from: Link.aboutUsURL.url) { [weak self] result in
            switch result {
            case .success(let info):
                print(info)
                self?.showAlert(withStatus: .success)
            case .failure(let error):
                print(error)
                self?.showAlert(withStatus: .failed)
            }
        }
    }
    
    private func fetchInfoAboutUsWithEmptyFields() {
        networkManager.fetch(SwiftbookInfo.self, from: Link.aboutUsURL2.url) { [weak self] result in
            switch result {
            case .success(let info):
                print(info)
                self?.showAlert(withStatus: .success)
            case .failure(let error):
                print(error)
                self?.showAlert(withStatus: .failed)
            }
        }
    }
    
    private func postRequestWithDict() {
        let parameters = [
            "name": "Networking",
            "imageUrl": "image url",
            "numberOfLessons": "10",
            "numberOfTests": "8"
        ]
        
        networkManager.postRequest(with: parameters, to: Link.postRequest.url) { [weak self] result in
            switch result {
            case .success(let json):
                print(json)
                self?.showAlert(withStatus: .success)
            case .failure(let error):
                print(error)
                self?.showAlert(withStatus: .failed)
            }
        }
    }
    
    private func postRequestWithModel() {
        let course = Course(
            name: "Networking",
            imageUrl: Link.courseImageURL.url,
            numberOfLessons: 10,
            numberOfTests: 5
        )
        
        networkManager.postRequest(with: course, to: Link.postRequest.url) { [weak self] result in
            switch result {
            case .success(let course):
                print(course)
                self?.showAlert(withStatus: .success)
            case .failure(let error):
                print(error)
                self?.showAlert(withStatus: .failed)
            }
        }
    }
}
