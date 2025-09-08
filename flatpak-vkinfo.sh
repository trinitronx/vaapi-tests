#!/bin/sh

freedesktop_vk_appid=org.freedesktop.Platform.VulkanInfo
freedesktop_vk_version=22.08

install_flatpak() {
  flatpak install flathub "${freedesktop_vk_appid}//${freedesktop_vk_version}"
}

installed() {
  flatpak list --columns=application,version | grep -E "${freedesktop_vk_appid}.*${freedesktop_vk_version}.*"
  return $?
}

if ! installed ; then
  echo "Flatpak '${freedesktop_vk_appid}//${freedesktop_vk_version}' not found!"
  echo 'You must install this tool for this script to function...'
  install_flatpak
fi

flatpak run --filesystem=host --share=network org.freedesktop.Platform.VulkanInfo//22.08
