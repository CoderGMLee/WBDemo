#!/bin/bash

#PackageApplication工具路径： /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/PackageApplication  如果没有此工具则需要去Xcode8.3之前的版本下载复制到此路径下

#-----------------------------配置参数----------------------------

#工程环境路径 /Users/liguomin/Desktop/Demos/WBDemo /Users/liguomin/Desktop/Dmall_iOS/ios2/Dmall2
workspace_path=/Users/liguomin/Desktop/Dmall_iOS/ios2/Dmall2
#项目名称
project_name=dmall
#项目文件
workspace_name=dmall.xcworkspace
#最终ipa生成地址
targe_path=/Users/liguomin/Desktop/WBIPA
#签名文件
sign_identity="iPhone Distribution: Dmall (beijing) E-commerce Co., Ltd."
#配置文件
provison_profile="c98c3b6d-f89c-4355-a634-b5aa6cb57a40"

#-----------------------------开始打包----------------------------
echo "准备开始打ipa包...................."

echo "进入项目工程文件: $workspace_path"

cd $workspace_path

echo "执行编译生成.app命令"

xcodebuild -workspace $workspace_name -scheme $project_name -sdk iphoneos -configuration Release clean build CODE_SIGN_IDENTITY="$sign_identity" PROVISIONING_PROFILE=$provison_profile -derivedDataPath $targe_path/build

echo "在项目工程文件内生成一个build子目录，里面有${project_name}.App程序"

echo "导出ipa包"

#.app生成后的路径
app_name_path=$targe_path/build/Build/Products/Release-iphoneos/${project_name}.app
#.ipa生成后的路径
ipa_name_path=$targe_path/build/Build/Products/Release-iphoneos/${project_name}.ipa

#生成ipa包
xcrun -sdk iphoneos PackageApplication -v $app_name_path -o $ipa_name_path

echo $'\n'
echo "制作ipa包完成......................."
echo $'\n'

cd $targe_path
time=`date "+%Y-%m-%d-%H-%M-%S"`
directoryName="$project_name$time"
mkdir $directoryName
mv $ipa_name_path $targe_path/$directoryName
rm -rf $targe_path/build

#-----------------------------上传蒲公英----------------------------
#echo "正在上传蒲公英..."
#curl -F "file=@$targe_path/$directoryName/$project_name.ipa" -F "uKey=c59532cf86833e5fa401a0b7fd6970f2" -F "_api_key=da45bb2402f639803c0624c5cf0ba93a" https://qiniu-storage.pgyer.com/apiv1/app/upload

echo $'\n'
echo "请前往    ${targe_path}/${directoryName}   查找ipa包"
echo $'\n'



