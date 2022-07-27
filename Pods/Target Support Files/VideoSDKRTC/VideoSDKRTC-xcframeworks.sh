#!/bin/sh
set -e
set -u
set -o pipefail

function on_error {
  echo "$(realpath -mq "${0}"):$1: error: Unexpected failure"
}
trap 'on_error $LINENO' ERR


# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")


<<<<<<< HEAD
variant_for_slice()
{
  case "$1" in
  "VideoSDKRTC.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "VideoSDKRTC.xcframework/ios-arm64")
    echo ""
    ;;
  "vl_mediasoup_client_ios.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "vl_mediasoup_client_ios.xcframework/ios-arm64")
    echo ""
    ;;
  "WebRTC.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "WebRTC.xcframework/ios-arm64")
    echo ""
    ;;
  esac
}

archs_for_slice()
{
  case "$1" in
  "VideoSDKRTC.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "VideoSDKRTC.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "vl_mediasoup_client_ios.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "vl_mediasoup_client_ios.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "WebRTC.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "WebRTC.xcframework/ios-arm64")
    echo "arm64"
    ;;
  esac
}

=======
>>>>>>> da4f5e8d577141b9b4a2514a23d7835bff88ca3b
copy_dir()
{
  local source="$1"
  local destination="$2"

  # Use filter instead of exclude so missing patterns don't throw errors.
  echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --links --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" \"${source}*\" \"${destination}\""
  rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --links --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" "${source}"/* "${destination}"
}

SELECT_SLICE_RETVAL=""

select_slice() {
<<<<<<< HEAD
  local xcframework_name="$1"
  xcframework_name="${xcframework_name##*/}"
  local paths=("${@:2}")
=======
  local paths=("$@")
>>>>>>> da4f5e8d577141b9b4a2514a23d7835bff88ca3b
  # Locate the correct slice of the .xcframework for the current architectures
  local target_path=""

  # Split archs on space so we can find a slice that has all the needed archs
  local target_archs=$(echo $ARCHS | tr " " "\n")

  local target_variant=""
  if [[ "$PLATFORM_NAME" == *"simulator" ]]; then
    target_variant="simulator"
  fi
  if [[ ! -z ${EFFECTIVE_PLATFORM_NAME+x} && "$EFFECTIVE_PLATFORM_NAME" == *"maccatalyst" ]]; then
    target_variant="maccatalyst"
  fi
  for i in ${!paths[@]}; do
    local matched_all_archs="1"
<<<<<<< HEAD
    local slice_archs="$(archs_for_slice "${xcframework_name}/${paths[$i]}")"
    local slice_variant="$(variant_for_slice "${xcframework_name}/${paths[$i]}")"
    for target_arch in $target_archs; do
      if ! [[ "${slice_variant}" == "$target_variant" ]]; then
=======
    for target_arch in $target_archs
    do
      if ! [[ "${paths[$i]}" == *"$target_variant"* ]]; then
        matched_all_archs="0"
        break
      fi

      # Verifies that the path contains the variant string (simulator or maccatalyst) if the variant is set.
      if [[ -z "$target_variant" && ("${paths[$i]}" == *"simulator"* || "${paths[$i]}" == *"maccatalyst"*) ]]; then
>>>>>>> da4f5e8d577141b9b4a2514a23d7835bff88ca3b
        matched_all_archs="0"
        break
      fi

<<<<<<< HEAD
      if ! echo "${slice_archs}" | tr " " "\n" | grep -F -q -x "$target_arch"; then
=======
      # This regex matches all possible variants of the arch in the folder name:
      # Let's say the folder name is: ios-armv7_armv7s_arm64_arm64e/CoconutLib.framework
      # We match the following: -armv7_, _armv7s_, _arm64_ and _arm64e/.
      # If we have a specific variant: ios-i386_x86_64-simulator/CoconutLib.framework
      # We match the following: -i386_ and _x86_64-
      # When the .xcframework wraps a static library, the folder name does not include
      # any .framework. In that case, the folder name can be: ios-arm64_armv7
      # We also match _armv7$ to handle that case.
      local target_arch_regex="[_\-]${target_arch}([\/_\-]|$)"
      if ! [[ "${paths[$i]}" =~ $target_arch_regex ]]; then
>>>>>>> da4f5e8d577141b9b4a2514a23d7835bff88ca3b
        matched_all_archs="0"
        break
      fi
    done

    if [[ "$matched_all_archs" == "1" ]]; then
      # Found a matching slice
      echo "Selected xcframework slice ${paths[$i]}"
      SELECT_SLICE_RETVAL=${paths[$i]}
      break
    fi
  done
}

install_xcframework() {
  local basepath="$1"
  local name="$2"
  local package_type="$3"
  local paths=("${@:4}")

  # Locate the correct slice of the .xcframework for the current architectures
<<<<<<< HEAD
  select_slice "${basepath}" "${paths[@]}"
  local target_path="$SELECT_SLICE_RETVAL"
  if [[ -z "$target_path" ]]; then
    echo "warning: [CP] $(basename ${basepath}): Unable to find matching slice in '${paths[@]}' for the current build architectures ($ARCHS) and platform (${EFFECTIVE_PLATFORM_NAME-${PLATFORM_NAME}})."
=======
  select_slice "${paths[@]}"
  local target_path="$SELECT_SLICE_RETVAL"
  if [[ -z "$target_path" ]]; then
    echo "warning: [CP] Unable to find matching .xcframework slice in '${paths[@]}' for the current build architectures ($ARCHS)."
>>>>>>> da4f5e8d577141b9b4a2514a23d7835bff88ca3b
    return
  fi
  local source="$basepath/$target_path"

  local destination="${PODS_XCFRAMEWORKS_BUILD_DIR}/${name}"

  if [ ! -d "$destination" ]; then
    mkdir -p "$destination"
  fi

  copy_dir "$source/" "$destination"
  echo "Copied $source to $destination"
}

<<<<<<< HEAD
install_xcframework "${PODS_ROOT}/VideoSDKRTC/Frameworks/VideoSDKRTC.xcframework" "VideoSDKRTC" "framework" "ios-arm64_x86_64-simulator" "ios-arm64"
install_xcframework "${PODS_ROOT}/VideoSDKRTC/Frameworks/vl_mediasoup_client_ios.xcframework" "VideoSDKRTC" "framework" "ios-arm64_x86_64-simulator" "ios-arm64"
install_xcframework "${PODS_ROOT}/VideoSDKRTC/Frameworks/WebRTC.xcframework" "VideoSDKRTC" "framework" "ios-arm64_x86_64-simulator" "ios-arm64"
=======
install_xcframework "${PODS_ROOT}/../Frameworks/VideoSDKRTC.xcframework" "VideoSDKRTC" "framework" "ios-arm64_x86_64-simulator" "ios-arm64"
install_xcframework "${PODS_ROOT}/../Frameworks/vl_mediasoup_client_ios.xcframework" "VideoSDKRTC" "framework" "ios-arm64_x86_64-simulator" "ios-arm64"
install_xcframework "${PODS_ROOT}/../Frameworks/WebRTC.xcframework" "VideoSDKRTC" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
>>>>>>> da4f5e8d577141b9b4a2514a23d7835bff88ca3b

