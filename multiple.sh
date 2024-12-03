#!/bin/bash

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "脚本由大赌社区哈哈哈哈编写，推特 @ferdie_jhovie，免费开源，请勿相信收费"
        echo "如有问题，可联系推特，仅此只有一个号"
        echo "新建了一个电报群，方便大家交流：t.me/Sdohua"
        echo "================================================================"
        echo "退出脚本，请按键盘 ctrl + C 退出即可"
        echo "请选择要执行的操作:"
        echo "1. 安装 Multiple"
        echo "2. 验证安装"
        echo "3. 查看日志"
        echo "4. 退出"
        read -p "请输入选项: " choice
        
        case $choice in
            1)
                install_multiple
                ;;
            2)
                verify_installation
                ;;
            3)
                view_logs
                ;;
            4)
                exit 0
                ;;
            *)
                echo "无效的选项，请重新选择。"
                sleep 2
                ;;
        esac
    done
}

# 安装Multiple的函数
function install_multiple() {
    # 下载程序
    if ! wget -O /tmp/multipleforlinux.tar https://cdn.app.multiple.cc/client/linux/x64/multipleforlinux.tar; then
        echo "下载程序失败，请检查网络连接。"
        return 1
    fi

    # 解压程序
    tar -xvf /tmp/multipleforlinux.tar -C /root/
    if [ $? -ne 0 ]; then
        echo "解压程序失败，请检查文件或权限。"
        return 1
    fi

    # 修改解压目录的权限
    chmod -R 777 /root/multipleforlinux

    # 添加权限
    chmod +x /root/multipleforlinux/multiple-cli
    chmod +x /root/multipleforlinux/multiple-node

    # 配置环境变量
    echo "正在配置环境变量..."
    echo 'PATH=$PATH:/root/multipleforlinux/multiple-cli' | sudo tee -a /etc/profile > /dev/null
    echo 'PATH=$PATH:/root/multipleforlinux/multiple-cli' >> ~/.bashrc
    source ~/.bashrc

    # 启动multiple-node
    nohup /root/multipleforlinux/multiple-node > /root/multipleforlinux/output.log 2>&1 &
    echo "Multiple 已安装并启动。"

    # 提示用户输入标识码和PIN码
    read -p "请输入唯一标识码: " identifier
    read -p "请输入PIN码: " pin

    # 使用用户提供的信息执行绑定命令
    /root/multipleforlinux/multiple-cli bind --bandwidth-download 100 --identifier "$identifier" --pin "$pin" --storage 200 --bandwidth-upload 100

    echo "绑定操作已完成。"
    
    # 清理压缩包
    rm /tmp/multipleforlinux.tar

    # 让用户按任意键返回主菜单
    read -p "按任意键返回主菜单..." -n1 -s
}

# 验证安装的函数
function verify_installation() {
    echo "正在验证安装..."
    /root/multipleforlinux/multiple-cli --version
    if [ $? -eq 0 ]; then
        echo "安装验证成功。"
    else
        echo "安装验证失败，请检查安装过程。"
    fi
    read -p "按任意键返回主菜单..." -n1 -s
}

# 查看日志的函数
function view_logs() {
    if [ -f "/root/multipleforlinux/output.log" ]; then
        less /root/multipleforlinux/output.log
    else
        echo "日志文件未找到。"
    fi
    read -p "按任意键返回主菜单..." -n1 -s
}

# 启动主菜单
main_menu
