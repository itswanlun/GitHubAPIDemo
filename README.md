# GitHubAPIDemo
## 設計方向

1. Pull-to-refresh下拉更新資料
2. Infinite scroll 捲軸瀏覽至底載入新資料，直到 API 沒有資料，footer 顯示 End
3. Login、Sign Up 頁面，keyboard 點擊 next 時，可以自動換下個 textField
4. 點擊 searchBar，跳出 keyboard 增加 toolBar 收回 Keyboard

## 使用技術

1. UIKit programmatically
2. 資料來源：[https://docs.github.com/en/rest/reference/search#search-repositories](https://docs.github.com/en/rest/reference/search#search-repositories)
3. 使用 MVVM 架構
4. 使用 CocoaPods 管理 third-party
5. 使用 third-party
    - RxSwift
    - RxCocoa
    - RxDataSources
    - Moya
    - Moya/RxSwift
    - RxSwiftExt
    - Firebase/Core
    - Firebase/Auth

## 如何使用

**Firebase 設定**

因為 GoogleService-Info.plist 包含 Google API Key，所以必須自行新增 GoogleService-Info.plist 到專案下，參考步驟如下：

1. 至 Firebase 新增專案
2. 取得 GoogleService-Info.plist 放入專案下
3. 至 Firebase 新增的專案下 ****Authentication > Sign in method**** ，增加一種登入方式
