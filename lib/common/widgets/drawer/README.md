# AppDrawer Widget

## Mô tả
`AppDrawer` là một widget có thể tái sử dụng, cung cấp sidebar navigation với các chức năng cơ bản cho ứng dụng.

## Tính năng
- 🧑‍💼 **Thông tin user**: Hiển thị avatar, tên và email từ Firebase Auth
- 🌙 **Dark Mode Toggle**: Chuyển đổi giữa chế độ sáng và tối
- 📱 **Menu Navigation**: Truy cập nhanh đến Profile, Settings
- ℹ️ **About Dialog**: Thông tin về ứng dụng
- 🚪 **Sign Out**: Đăng xuất với xác nhận

## Cách sử dụng

### 1. Import widget
```dart
import 'package:app_nghenhac/common/widgets/drawer/app_drawer.dart';
```

### 2. Thêm vào Scaffold

#### Drawer bên phải (endDrawer):
```dart
Scaffold(
  appBar: AppBar(
    title: Text('Tên trang'),
    actions: [
      Builder(
        builder: (context) => IconButton(
          onPressed: () => Scaffold.of(context).openEndDrawer(),
          icon: Icon(Icons.menu),
        ),
      ),
    ],
  ),
  endDrawer: const AppDrawer(),
  body: YourContent(),
)
```

#### Drawer bên trái (drawer):
```dart
Scaffold(
  appBar: AppBar(
    title: Text('Tên trang'),
  ),
  drawer: const AppDrawer(),
  body: YourContent(),
)
```

### 3. Tự động với BasicAppbar
Nếu sử dụng `BasicAppbar`, chỉ cần:
```dart
Scaffold(
  appBar: BasicAppbar(
    title: Text('Tên trang'),
    action: Builder(
      builder: (context) => IconButton(
        onPressed: () => Scaffold.of(context).openEndDrawer(),
        icon: Icon(Icons.menu),
      ),
    ),
  ),
  endDrawer: const AppDrawer(),
  body: YourContent(),
)
```

## Dependencies cần thiết
```yaml
dependencies:
  firebase_auth: ^5.3.3
  flutter_bloc: ^8.1.3
```

## Các class liên quan
- `GoogleSignInService`: Xử lý đăng xuất
- `ThemeCubit`: Quản lý dark/light mode
- `AppColors`: Theme colors
- `ProfilePage`: Trang hồ sơ user
- `SigninPage`: Trang đăng nhập

## Tùy chỉnh
Bạn có thể tùy chỉnh `AppDrawer` bằng cách:
1. Thêm/bớt menu items trong file `app_drawer.dart`
2. Thay đổi colors trong `AppColors`
3. Tùy chỉnh header layout
4. Thêm navigation items mới

## File location
`lib/common/widgets/drawer/app_drawer.dart`