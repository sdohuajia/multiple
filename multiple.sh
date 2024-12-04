#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/multiple.sh"

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
        echo "3. 删除节点"
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
                uninstall_multiple
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
    # 下载程序并添加错误处理
    echo "正在下载 Multiple..."
    if ! wget -O /root/multipleforlinux.tar https://cdn.app.multiple.cc/client/linux/x64/multipleforlinux.tar; then
        echo "下载失败，请检查网络连接"
        return 1
    fi

    # 清理可能存在的旧文件
    rm -rf /root/multipleforlinux

    # 解压程序
    echo "正在解压文件..."
    if ! tar xf /root/multipleforlinux.tar -C /root; then
        echo "解压失败"
        return 1
    fi

    # 确保在正确的目录下执行权限设置
    cd "/root/multipleforlinux"
    if [ ! -f "./multiple-cli" ]; then
        echo "multiple-cli 文件不存在，请检查下载和解压过程。"
        return 1
    fi
    chmod +x multiple-cli 
    chmod +x multiple-node

    # 给整个目录授权
    cd /root
    chmod -R 777 /root/multipleforlinux

    # 配置环境变量
    echo "正在配置环境变量..."
    
    # 确保路径变量被添加到 /etc/profile 文件的末尾
    if ! echo 'PATH=$PATH:/root/multipleforlinux/' | sudo tee -a /etc/profile; then
        echo "配置环境变量失败，请检查权限或空间。"
        return 1
    fi
    
    # 重新加载环境变量
    source /etc/profile

    # 启动multiple-node
    nohup /root/multipleforlinux/multiple-node > /root/output.log 2>&1 &
    echo "Multiple 已安装并启动。"

    # 提示用户输入标识码和PIN码
    read -p "请输入唯一标识码: " identifier
    read -p "请输入PIN码: " pin

    # 使用用户提供的信息执行绑定命令
    cd /root/multipleforlinux
    if ! ./multiple-cli bind --bandwidth-download 100 --identifier "$identifier" --pin "$pin" --storage 200 --bandwidth-upload 100; then
        echo "绑定操作失败，请检查输入信息或网络连接。"
    else
        echo "绑定操作已完成。"
    fi

    # 清理文件
    rm -f /root/multipleforlinux.tar

    echo "Multiple 安装完成！"
    read -p "按任意键返回主菜单..." -n1 -s
}

# 验证安装的函数
function verify_installation() {
    echo "正在验证安装..."
    if ! /root/multipleforlinux/multiple-cli --version; then
        echo "安装验证失败，请检查安装过程。"
    else
        echo "安装验证成功。"
    fi
    read -p "按任意键返回主菜单..." -n1 -s
}

# 删除Multiple函数
function uninstall_multiple() {
    echo "正在删除 Multiple..."
    # 停止 multiple-node 进程
    pkill -f multiple-node
    
    # 删除程序文件
    rm -rf ~/multipleforlinux
    rm -rf /root/multipleforlinux
    
    # 清理环境变量配置
    sudo sed -i '/PATH=$PATH:\/root\/multipleforlinux/d' /etc/profile
    sed -i '/PATH=$PATH:\/root\/multipleforlinux/d' ~/.bashrc
    
    # 重新加载环境变量
    source /etc/profile
    source ~/.bashrc
    
    echo "Multiple 已成功删除"
    read -p "按任意键返回主菜单..." -n1 -s
}

# 启动主菜单
main_menu
