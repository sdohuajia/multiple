#!/bin/bash

# 设置代理环境变量的函数
function set_proxy() {
    if [ -f "/tmp/multipleforlinux/multipleforlinux/proxy.txt" ]; then
        # 读取代理服务器的列表
        mapfile -t proxies < "/tmp/multipleforlinux/multipleforlinux/proxy.txt"
    else
        echo "未找到proxy.txt文件，代理将不使用。"
        proxies=()
    fi
}

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
        echo "3. 使用代理模式多开"
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
                use_proxy_mode
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
    # 创建一个新的multipleforlinux目录
    mkdir -p /tmp/multipleforlinux
    cd /tmp/multipleforlinux

    # 下载程序
    if ! wget -O multipleforlinux.tar https://cdn.app.multiple.cc/client/linux/x64/multipleforlinux.tar; then
        echo "下载程序失败，请检查网络连接。"
        return 1
    fi

    # 解压程序
    tar -xvf multipleforlinux.tar
    if [ $? -ne 0 ]; then
        echo "解压程序失败，请检查文件或权限。"
        return 1
    fi

    # 修改解压目录的权限
    chmod -R 777 multipleforlinux

    # 添加权限
    chmod +x /tmp/multipleforlinux/multipleforlinux/multiple-cli
    chmod +x /tmp/multipleforlinux/multipleforlinux/multiple-node

    # 配置环境变量
    echo "正在配置环境变量..."
    echo 'PATH=$PATH:/tmp/multipleforlinux/multipleforlinux/multiple-cli' | sudo tee -a /etc/profile > /dev/null
    echo 'PATH=$PATH:/tmp/multipleforlinux/multipleforlinux/multiple-cli' >> ~/.bashrc
    source ~/.bashrc

    # 启动multiple-node
    nohup /tmp/multipleforlinux/multipleforlinux/multiple-node > /tmp/multipleforlinux/multipleforlinux/output.log 2>&1 &
    echo "Multiple 已安装并启动。"

    # 提示用户输入标识码和PIN码
    read -p "请输入唯一标识码: " identifier
    read -p "请输入PIN码: " pin

    # 使用用户提供的信息执行绑定命令
    /tmp/multipleforlinux/multipleforlinux/multiple-cli bind --bandwidth-download 100 --identifier "$identifier" --pin "$pin" --storage 200 --bandwidth-upload 100

    echo "绑定操作已完成。"
    
    # 清理压缩包
    rm /tmp/multipleforlinux/multipleforlinux.tar

    # 让用户按任意键返回主菜单
    read -p "按任意键返回主菜单..." -n1 -s
}

# 使用代理模式多开Multiple的函数
function use_proxy_mode() {
    # 创建proxy.txt文件并让用户填写代理
    echo "请填写代理服务器地址和端口，每行一个代理，按回车继续，空白不填按回车即可完成。"
    touch /tmp/multipleforlinux/multipleforlinux/proxy.txt
    while true; do
        read -p "代理服务器地址: " proxy_server
        if [ -z "$proxy_server" ]; then
            break
        fi
        read -p "代理服务器端口: " proxy_port
        if [ -z "$proxy_port" ]; then
            break
        fi
        echo "$proxy_server:$proxy_port" >> /tmp/multipleforlinux/multipleforlinux/proxy.txt
    done

    set_proxy

    # 询问用户想多开几个实例
    read -p "请输入想要多开的实例数量: " num_instances

    # 检查输入是否为数字
    if ! [[ "$num_instances" =~ ^[0-9]+$ ]]; then
        echo "请输入有效的数字。"
        return 1
    fi

    # 循环创建和启动实例
    for (( i=1; i<=$num_instances; i++ )); do
        if [ ${#proxies[@]} -ge $i ]; then
            export http_proxy="http://${proxies[i-1]}"
            export https_proxy="http://${proxies[i-1]}"
            export ftp_proxy="http://${proxies[i-1]}"
            echo "代理已设置为 ${proxies[i-1]}"
        else
            echo "代理服务器列表不足，实例 $i 将不使用代理。"
        fi
        
        echo "正在安装和启动第 $i 个实例..."
        install_multiple
    done

    echo "所有实例已安装并启动。"
    read -p "按任意键返回主菜单..." -n1 -s
}

# 验证安装的函数
function verify_installation() {
    echo "正在验证安装..."
    /tmp/multipleforlinux/multipleforlinux/multiple-cli --version
    if [ $? -eq 0 ]; then
        echo "安装验证成功。"
    else
        echo "安装验证失败，请检查安装过程。"
    fi
    read -p "按任意键返回主菜单..." -n1 -s
}

# 启动主菜单
main_menu
