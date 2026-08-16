import React, { useState } from 'react';
import styles from './styles.module.css';

interface CommandItem {
  id: string;
  name: string;
  category: 'power' | 'wifi' | 'display' | 'system';
  cmd: string;
  desc: string;
}

const COMMAND_PRESETS: CommandItem[] = [
  {
    id: 'prevent-sleep',
    name: '🔒 阻止休眠常亮',
    category: 'power',
    cmd: 'lipc-set-prop com.lab126.powerd preventScreenSaver 1',
    desc: '使 Kindle 屏幕永久常亮，进入开发调试看板模式，不触发系统超时锁屏。',
  },
  {
    id: 'allow-sleep',
    name: '🔓 恢复自动休眠',
    category: 'power',
    cmd: 'lipc-set-prop com.lab126.powerd preventScreenSaver 0',
    desc: '恢复 Kindle 原生电源策略，静置几分钟后自动进入低功耗休眠锁屏。',
  },
  {
    id: 'get-battery',
    name: '🔋 查询剩余电量',
    category: 'power',
    cmd: 'lipc-get-prop com.lab126.powerd battLevel',
    desc: '从电源管理总线实时读取当前电池剩余电量百分比数字（0 ~ 100）。',
  },
  {
    id: 'disable-wifi',
    name: '🔌 彻底关闭 Wi-Fi',
    category: 'wifi',
    cmd: 'lipc-set-prop com.lab126.wifid enable 0',
    desc: '关闭无线网卡射频芯片供电（这是墨水屏看板实现数月超长续航的关键）。',
  },
  {
    id: 'enable-wifi',
    name: '📶 重新开启 Wi-Fi',
    category: 'wifi',
    cmd: 'lipc-set-prop com.lab126.wifid enable 1',
    desc: '开启无线网卡供电并自动重连已保存的 Wi-Fi 热点。',
  },
  {
    id: 'refresh-screen',
    name: '✨ 全屏反转刷屏',
    category: 'display',
    cmd: 'lipc-set-prop com.lab126.appmgrd refreshScreen 1',
    desc: '触发底层 EPDC 控制器进行一次黑白全屏闪烁刷新，彻底清除残影。',
  },
  {
    id: 'stop-framework',
    name: '🛑 停止原生 UI 界面',
    category: 'system',
    cmd: 'stop framework',
    desc: '停止亚马逊 Java 阅读器主框架，释放约 150MB 内存与后台 CPU 占用。',
  },
  {
    id: 'start-framework',
    name: '▶️ 重启原生阅读器',
    category: 'system',
    cmd: 'start framework',
    desc: '重新启动亚马逊官方阅读器主界面与书库服务。',
  },
];

export default function LipcCommandGenerator(): JSX.Element {
  const [selectedCmd, setSelectedCmd] = useState<CommandItem>(COMMAND_PRESETS[0]);
  const [copied, setCopied] = useState<boolean>(false);

  const handleCopy = () => {
    navigator.clipboard.writeText(selectedCmd.cmd);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <span className={styles.badge}>MDX 交互组件</span>
        <h4 className={styles.title}>LIPC 底层进程通信指令生成器</h4>
      </div>

      {/* Preset Buttons Grid */}
      <div className={styles.presetsGrid}>
        {COMMAND_PRESETS.map((item) => (
          <button
            key={item.id}
            type="button"
            className={`${styles.presetBtn} ${
              selectedCmd.id === item.id ? styles.presetBtnActive : ''
            }`}
            onClick={() => setSelectedCmd(item)}
          >
            {item.name}
          </button>
        ))}
      </div>

      {/* Command Details Box */}
      <div className={styles.detailBox}>
        <div className={styles.detailHeader}>
          <span className={styles.cmdTitle}>{selectedCmd.name}</span>
          <button type="button" onClick={handleCopy} className={styles.copyBtn}>
            {copied ? '✅ 已复制' : '📋 复制命令'}
          </button>
        </div>
        <div className={styles.codeBlock}>
          <code>{selectedCmd.cmd}</code>
        </div>
        <p className={styles.desc}>{selectedCmd.desc}</p>
        <div className={styles.sshRow}>
          <span className={styles.sshLabel}>SSH 直连运行写法:</span>
          <code>ssh kindle &quot;{selectedCmd.cmd}&quot;</code>
        </div>
      </div>
    </div>
  );
}
