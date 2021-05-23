# .app 产物路径
BUILD_APP_PATH="${BUILT_PRODUCTS_DIR}/${TARGET_NAME}.app"
# 待拷贝的 .app 路径
TARGET_APP_PUT_PATH="${SRCROOT}/${TARGET_NAME}/TargetApp"
# 当前工程的 Info.plist 路径
TARGET_INFO_PLIST="${SRCROOT}/${INFOPLIST_FILE}"
# 拷贝 .app 中所有文件
COPY_APP_PATH=$(find "${TARGET_APP_PUT_PATH}" -type d | grep "\.app$" | head -n 1)

if [ -z "${COPY_APP_PATH}" ]; then
  echo "未能在 ${TARGET_APP_PUT_PATH} 路径下找到 *.app"
	exit 1
fi

cp -rf "${COPY_APP_PATH}/" "${BUILD_APP_PATH}/"
# 移除不考虑支持的 PlugIns 和 Watch
rm -rf "${BUILD_APP_PATH}/PlugIns" "${BUILD_APP_PATH}/Watch" || true

cp -rf "${COPY_APP_PATH}/Info.plist" "${TARGET_INFO_PLIST}"
/usr/libexec/PlistBuddy -c "Delete :UIDeviceFamily" "${TARGET_INFO_PLIST}"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ${PRODUCT_BUNDLE_IDENTIFIER}" "${TARGET_INFO_PLIST}"
cp -rf "${TARGET_INFO_PLIST}" "${BUILD_APP_PATH}/Info.plist"

if [ -d "${BUILD_APP_PATH}/Frameworks" ]; then
	for library in "${BUILD_APP_PATH}/Frameworks"/*; do
		/usr/bin/codesign --force --sign "${EXPANDED_CODE_SIGN_IDENTITY}" --timestamp\=none --preserve-metadata\=identifier,entitlements,flags "${library}"
	done
fi
