# Merge origin/main into current branch

Fetch và merge code mới nhất từ origin/main vào nhánh hiện tại, tự động resolve conflicts nếu có. Nếu nhánh hiện tại là `main` (track `fork/main`), sẽ push update lên fork sau khi merge thành công.

## Steps

1. **Fetch và merge từ origin/main**
   ```bash
   git fetch origin main --tags && git merge origin/main
   ```

2. **Nếu có conflicts:**
   - Đọc các file bị conflict (git sẽ báo trong output)
   - Phân tích conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
   - Resolve bằng cách:
     - Giữ code từ cả 2 bên nếu cần thiết
     - Hoặc chọn 1 bên phù hợp
     - Xóa hết conflict markers

3. **Verify không còn conflict markers:**
   ```bash
   grep -r "<<<<<<" --include="*.rs" --include="*.swift" . || echo "No conflict markers"
   ```

4. **Commit merge (PHẢI commit trước khi build để `git describe` lấy đúng version):**
   ```bash
   git add -A && git commit -m "Merge origin/main into $(git branch --show-current)"
   ```

5. **Push lên fork nếu đang ở nhánh `main` (track `fork/main`):**
   ```bash
   if [ "$(git branch --show-current)" = "main" ]; then
     git push fork main
   fi
   ```
   - Chỉ push khi current branch là `main` và upstream là `fork/main`
   - Dùng push thường (không cần force) vì chỉ fast-forward từ origin/main

6. **Build Rust core:**
   ```bash
   cd core && cargo test && cd ..
   ./scripts/build/core.sh
   ```

7. **Build macOS app với xcodebuild:**
   ```bash
   xcodebuild -project platforms/macos/GoNhanh.xcodeproj \
     -scheme GoNhanh -configuration Release \
     -destination 'platform=macOS,arch=arm64' \
     -derivedDataPath "platforms/macos/build/DerivedData" \
     MARKETING_VERSION="$(git describe --tags --abbrev=0 --match 'v*' --exclude 'v*-pre*' | sed 's/^v//')" \
     CURRENT_PROJECT_VERSION="$(git describe --tags --abbrev=0 --match 'v*' --exclude 'v*-pre*' | sed 's/^v//')" \
     build
   ```

8. **Sign và copy vào build/Release:**
   ```bash
   mkdir -p platforms/macos/build/Release
   cp -R platforms/macos/build/DerivedData/Build/Products/Release/GoNhanh.app platforms/macos/build/Release/
   codesign --force --deep --sign - --entitlements platforms/macos/GoNhanh.entitlements platforms/macos/build/Release/GoNhanh.app
   ```

9. **Kill app cũ, copy vào /Applications, mở app mới:**
   - Phải kill app cũ trước, chờ process tắt hẳn, rồi mới copy và mở app mới
   ```bash
   killall GoNhanh 2>/dev/null; sleep 1
   ```
   ```bash
   cp -R platforms/macos/build/Release/GoNhanh.app /Applications/
   ```
   ```bash
   open /Applications/GoNhanh.app
   ```

## Notes

- Khi resolve conflicts, ưu tiên giữ cả 2 features nếu chúng không mâu thuẫn
- Nếu tests fail sau merge, đó có thể là issues đã có sẵn, không phải do merge
- Commit merge TRƯỚC khi build để `git describe --tags` lấy đúng version từ origin/main
- Nếu xcodebuild lỗi plugin, chạy `xcodebuild -runFirstLaunch` trước
- Nếu `clean` bị permission denied, bỏ `clean` chỉ chạy `build`
