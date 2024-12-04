#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/multiple.sh"

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
        echo "3. 使用代理模式多开（不可用）"
        echo "4. 删除节点"
        echo "5. 退出"
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
                uninstall_multiple
                ;;
            5)
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
# 安装Multiple的函数
function install_multiple() {
    # 创建安装目录
    INSTALL_DIR="/root/multipleforlinux"
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"

    # 下载程序并添加错误处理
    echo "正在下载 Multiple..."
    if ! wget -O multipleforlinux.tar https://cdn.app.multiple.cc/client/linux/x64/multipleforlinux.tar; then
        echo "下载失败，请检查网络连接"
        return 1
    fi

    # 解压前清理可能存在的旧文件
    rm -rf multiple-cli multiple-node

    # 解压程序
    echo "正在解压文件..."
    if ! tar xf multipleforlinux.tar; then
        echo "解压失败"
        return 1
    fi

    # 修改文件权限
    chmod -R 777 .
    
    # 进入解压后的目录
    cd multipleforlinux
    
    # 设置执行权限
    chmod +x multiple-cli multiple-node

    # 配置环境变量
    echo "正在配置环境变量..."
    echo 'PATH=$PATH:/root/multipleforlinux' | sudo tee -a /etc/profile > /dev/null
    echo 'PATH=$PATH:/root/multipleforlinux' >> ~/.bashrc
    source /etc/profile
    source ~/.bashrc

    # 启动服务前先检查是否已运行
    echo "正在启动服务..."
    pkill multiple-node
    sleep 2
    nohup ./multiple-node > ./output.log 2>&1 &

    # 等待服务启动
    sleep 5

    # 检查服务是否正常运行
    if ! pgrep multiple-node > /dev/null; then
        echo "服务启动失败，请检查 output.log"
        return 1
    fi

    # 用户输入验证
    while true; do
        read -p "请输入唯一标识码: " identifier
        if [ -n "$identifier" ]; then
            break
        fi
        echo "标识码不能为空，请重新输入"
    done

    while true; do
        read -p "请输入PIN码: " pin
        if [ -n "$pin" ]; then
            break
        fi
        echo "PIN码不能为空，请重新输入"
    done

    # 执行绑定命令
    echo "正在执行绑定..."
    if ! ./multiple-cli bind --bandwidth-download 100 --identifier "$identifier" --pin "$pin" --storage 200 --bandwidth-upload 100; then
        echo "绑定失败，请检查标识码和PIN码是否正确"
        return 1
    fi

    # 清理文件
    rm -f multipleforlinux.tar

    echo "Multiple 安装完成！"
    read -p "按任意键返回主菜单..." -n1 -s
}

# 使用代理模式多开Multiple的函数
function use_proxy_mode() {
    # 创建proxy.txt文件并让用户填写代理
    echo "请填写代理服务器地址，按回车继续，空白不填按回车即可完成。"
    echo "例如：socks5://user:pass@proxy.example.com:port"
    touch /tmp/multipleforlinux/multipleforlinux/proxy.txt
    while true; do
        read -p "代理服务器地址: " proxy
        if [ -z "$proxy" ]; then
            break
        fi
        echo "$proxy" >> /tmp/multipleforlinux/multipleforlinux/proxy.txt
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
            export http_proxy="${proxies[i-1]}"
            export https_proxy="${proxies[i-1]}"
            export ftp_proxy="${proxies[i-1]}"
            if [[ ${proxies[i-1]} =~ ^socks5:// ]]; then
                export all_proxy="${proxies[i-1]}"
                echo "SOCKS5代理已设置为 ${proxies[i-1]}"
            else
                echo "HTTP代理已设置为 ${proxies[i-1]}"
            fi
        else
            echo "代理服务器列表不足，实例 $i 将不使用代理。"
        fi
        
        # 创建一个新的实例目录并复制文件
        mkdir -p "/tmp/multipleforlinux_instance$i"
        cp -r /tmp/multipleforlinux/multipleforlinux/* "/tmp/multipleforlinux_instance$i/"
        
        # 修改权限
        chmod -R 777 "/tmp/multipleforlinux_instance$i"

        # 添加权限
        chmod +x "/tmp/multipleforlinux_instance$i/multiple-cli"
        chmod +x "/tmp/multipleforlinux_instance$i/multiple-node"

        # 启动multiple-node
        nohup "/tmp/multipleforlinux_instance$i/multiple-node" > "/tmp/multipleforlinux_instance$i/output.log" 2>&1 &
        echo "第 $i 个实例已安装并启动。"

        # 提示用户输入标识码和PIN码
        read -p "请输入唯一标识码: " identifier
        read -p "请输入PIN码: " pin

        # 使用用户提供的信息执行绑定命令
        "/tmp/multipleforlinux_instance$i/multiple-cli" bind --bandwidth-download 100 --identifier "$identifier" --pin "$pin" --storage 200 --bandwidth-upload 100

        echo "绑定操作已完成。"
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

# 删除Multiple函数
function uninstall_multiple() {
    echo "正在删除 Multiple..."
    # 停止 multiple-node 进程
    pkill -f multiple-node
    
    # 删除程序文件
    rm -rf ~/multipleforlinux
    rm -rf /root/multipleforlinux
    
    # 清理环境变量配置
    sed -i '/PATH=$PATH:\/root\/multipleforlinux/d' /etc/profile
    sed -i '/PATH=$PATH:\/root\/multipleforlinux/d' ~/.bashrc
    
    # 重新加载环境变量
    source /etc/profile
    source ~/.bashrc
    
    echo "Multiple 已成功删除"
    read -p "按任意键返回主菜单..." -n1 -s
}

# 启动主菜单
main_menu
