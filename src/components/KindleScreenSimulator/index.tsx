import React, { useState } from 'react';
import styles from './styles.module.css';

interface TextLine {
  id: number;
  row: number;
  col: number;
  text: string;
}

export default function KindleScreenSimulator(): JSX.Element {
  const [lines, setLines] = useState<TextLine[]>([
    { id: 1, row: 2, col: 4, text: '============================' },
    { id: 2, row: 3, col: 4, text: '  SSH Wi-Fi Connected OK!  ' },
    { id: 3, row: 4, col: 4, text: '  Antigravity x Kindle K8   ' },
    { id: 4, row: 5, col: 4, text: '============================' },
  ]);
  const [inputRow, setInputRow] = useState<number>(7);
  const [inputCol, setInputCol] = useState<number>(4);
  const [inputText, setInputText] = useState<string>('Hello from Wiki!');
  const [isFlashing, setIsFlashing] = useState<boolean>(false);
  const [batteryLevel, setBatteryLevel] = useState<number>(85);

  const handlePrint = (e: React.FormEvent) => {
    e.preventDefault();
    if (!inputText.trim()) return;
    const newLine: TextLine = {
      id: Date.now(),
      row: Number(inputRow),
      col: Number(inputCol),
      text: inputText,
    };
    setLines([...lines, newLine]);
    setInputRow((prev) => (prev < 18 ? prev + 1 : 2));
  };

  const handleClearScreen = () => {
    setIsFlashing(true);
    setTimeout(() => {
      setLines([]);
      setIsFlashing(false);
    }, 450);
  };

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <div className={styles.titleGroup}>
          <span className={styles.badge}>MDX 交互组件</span>
          <h4 className={styles.title}>Kindle 8 墨水屏在线模拟器 (E-Ink Simulator)</h4>
        </div>
        <div className={styles.battery}>
          <span>🔋 电量: {batteryLevel}%</span>
        </div>
      </div>

      <div className={styles.deviceWrapper}>
        {/* Kindle Device Frame */}
        <div className={styles.kindleFrame}>
          <div className={styles.brandTop}>kindle</div>
          <div className={`${styles.einkScreen} ${isFlashing ? styles.flashing : ''}`}>
            {/* Top Status Bar */}
            <div className={styles.statusBar}>
              <span>12:00</span>
              <span>Wi-Fi: 192.168.31.74</span>
              <span>85% 🔋</span>
            </div>

            {/* Screen Content Grid */}
            <div className={styles.screenCanvas}>
              {lines.length === 0 ? (
                <div className={styles.emptyPrompt}>
                  [屏幕已清空 (eips -c) · 请在下方输入内容测试 eips 打印]
                </div>
              ) : (
                lines.map((line) => (
                  <div
                    key={line.id}
                    className={styles.canvasText}
                    style={{
                      top: `${line.row * 16}px`,
                      left: `${line.col * 10}px`,
                    }}
                  >
                    {line.text}
                  </div>
                ))
              )}
            </div>
          </div>
          <div className={styles.bottomBezel}>amazon</div>
        </div>

        {/* Control Panel */}
        <div className={styles.controlPanel}>
          <form onSubmit={handlePrint} className={styles.form}>
            <div className={styles.formRow}>
              <div className={styles.inputGroup}>
                <label>行 (Row):</label>
                <input
                  type="number"
                  min="0"
                  max="20"
                  value={inputRow}
                  onChange={(e) => setInputRow(Number(e.target.value))}
                />
              </div>
              <div className={styles.inputGroup}>
                <label>列 (Col):</label>
                <input
                  type="number"
                  min="0"
                  max="40"
                  value={inputCol}
                  onChange={(e) => setInputCol(Number(e.target.value))}
                />
              </div>
            </div>

            <div className={styles.inputGroupFull}>
              <label>输出文字 (String):</label>
              <input
                type="text"
                value={inputText}
                onChange={(e) => setInputText(e.target.value)}
                placeholder="输入要显示的字符串"
              />
            </div>

            <div className={styles.buttonRow}>
              <button type="submit" className={styles.btnPrimary}>
                🖋️ eips {inputRow} {inputCol} &quot;{inputText}&quot;
              </button>
              <button
                type="button"
                onClick={handleClearScreen}
                className={styles.btnSecondary}
              >
                🔄 eips -c (全刷清屏)
              </button>
            </div>
          </form>

          <div className={styles.commandPreview}>
            <span className={styles.cmdLabel}>当前生成的 SSH 终端指令:</span>
            <code>ssh kindle &quot;eips {inputRow} {inputCol} &apos;{inputText}&apos;&quot;</code>
          </div>
        </div>
      </div>
    </div>
  );
}
