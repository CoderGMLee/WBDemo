#!/bin/bash

#-----------------------------配置参数----------------------------

#工程环境路径 /Users/liguomin/Desktop/Demos/WBDemo /Users/liguomin/Desktop/Dmall_iOS/ios2/Dmall2
workspace_path=/Users/liguomin/Desktop/Dmall_iOS/ios2/Dmall2
#项目名称
project_name=dmall
#最终ipa生成地址
targe_path=/Users/liguomin/Desktop/WBIPA
#签名文件
sign_identity="iPhone Distribution: Dmall (beijing) E-commerce Co., Ltd."
#配置文件
provison_profile="c98c3b6d-f89c-4355-a634-b5aa6cb57a40"

time_id=7FLPKND722

#-----------------------------开始打包----------------------------
echo "准备开始打ipa包...................."

#项目文件
workspace_name=$project_name.xcworkspace


cd $workspace_path

#编译生成.xcarchive文件
xcodebuild -workspace $workspace_name -scheme $project_name -sdk iphoneos -configuration Release clean build CODE_SIGN_IDENTITY="$sign_identity" PROVISIONING_PROFILE=$provison_profile -derivedDataPath $targe_path/build -archivePath $targe_path/build/$project_name.xcarchive archive


plistDir=$targe_path/build/optionsPlist.plist

#生成plist文件
cat << EOF > $plistDir
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>method</key>
<string>enterprise</string>
<key>teamID</key>
<string>$time_id</string>
<key>compileBitcode</key>
<false/>
</dict>
</plist>
EOF

#打包生成.ipa文件
xcodebuild -exportArchive -archivePath $targe_path/build/$project_name.xcarchive -exportOptionsPlist $plistDir -exportPath $targe_path/build

echo $'\n'
echo "制作ipa包完成......................."
echo $'\n'

cd $targe_path
time=`date "+%Y-%m-%d-%H-%M-%S"`
directoryName="$project_name$time"
mkdir $directoryName
mv $targe_path/build/$project_name.ipa $targe_path/$directoryName
rm -rf $targe_path/build

#-----------------------------上传蒲公英----------------------------
#echo "正在上传蒲公英..."
#curl -F "file=@$targe_path/$directoryName/$project_name.ipa" -F "uKey=c59532cf86833e5fa401a0b7fd6970f2" -F "_api_key=da45bb2402f639803c0624c5cf0ba93a" https://qiniu-storage.pgyer.com/apiv1/app/upload
#
#echo $'\n'
#echo "请前往    ${targe_path}/${directoryName}   查找ipa包"
#echo $'\n'



