addimport React, { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { Delete, HelpCircle, Landmark, Percent, RefreshCw } from "lucide-react";

const evaluateExpression = (expr: string): number => {
  const sanitized = expr.replace(/×/g, "*").replace(/÷/g, "/").replace(/[^0-9+\-*/.]/g, "");
  const tokens: string[] = [];
  let currentNum = "";
  for (let i = 0; i < sanitized.length; i++) {
    const char = sanitized[i];
    if (["+", "-", "*", "/"].includes(char)) {
      if (currentNum) {
        tokens.push(currentNum);
        currentNum = "";
      }
      if (char === "-" && (tokens.length === 0 || ["+", "-", "*", "/"].includes(tokens[tokens.length - 1]))) {
        currentNum = "-";
      } else {
        tokens.push(char);
      }
    } else {
      currentNum += char;
    }
  }
  if (currentNum) {
    tokens.push(currentNum);
  }

  const phase1: string[] = [];
  let i = 0;
  while (i < tokens.length) {
    const token = tokens[i];
    if (token === "*" || token === "/") {
      const prev = parseFloat(phase1.pop() || "0");
      const next = parseFloat(tokens[i + 1] || "0");
      const res = token === "*" ? prev * next : prev / next;
      phase1.push(String(res));
      i += 2;
    } else {
      phase1.push(token);
      i++;
    }
  }

  let result = parseFloat(phase1[0] || "0");
  let j = 1;
  while (j < phase1.length) {
    const op = phase1[j];
    const val = parseFloat(phase1[j + 1] || "0");
    if (op === "+") {
      result += val;
    } else if (op === "-") {
      result -= val;
    }
    j += 2;
  }
  return result;
};

export default function Calculator() {
  const [calcMode, setCalcMode] = useState<"standard" | "splitter">("standard");

  // Standard Calc State
  const [display, setDisplay] = useState("");
  const [equation, setEquation] = useState("");
  const [isDone, setIsDone] = useState(false);

  // Splitter State
  const [totalAmount, setTotalAmount] = useState<number | "">("");
  const [splitterRatio, setSplitterRatio] = useState<"50-30-20" | "70-20-10" | "80-20">("50-30-20");

  const handleKeyPress = (val: string) => {
    if (isDone) {
      if (["+", "-", "*", "/"].includes(val)) {
        setDisplay(display + val);
        setEquation(display + val);
      } else {
        setDisplay(val);
        setEquation(val);
      }
      setIsDone(false);
      return;
    }

    if (display === "0" && !isNaN(Number(val))) {
      setDisplay(val);
      setEquation(val);
      return;
    }

    setDisplay(display + val);
    setEquation(equation + val);
  };

  const handleOperator = (op: string) => {
    if (display === "" && op === "-") {
      setDisplay("-");
      setEquation("-");
      return;
    }

    if (display === "" || ["+", "-", "*", "/"].includes(display.slice(-1))) return;

    setDisplay(display + op);
    setEquation(equation + op);
    setIsDone(false);
  };

  const handleClear = () => {
    setDisplay("");
    setEquation("");
    setIsDone(false);
  };

  const handleBackspace = () => {
    if (isDone) {
      handleClear();
      return;
    }
    setDisplay(display.slice(0, -1));
    setEquation(equation.slice(0, -1));
  };

  const handleEvaluate = () => {
    if (display === "") return;
    try {
      const result = evaluateExpression(equation);
      if (isNaN(result) || !isFinite(result)) {
        setDisplay("Error");
      } else {
        const rounded = parseFloat(result.toFixed(4));
        setDisplay(String(rounded));
        setEquation(equation + " =");
        setIsDone(true);
      }
    } catch {
      setDisplay("Error");
    }
  };

  const calculateSplit = () => {
    const amt = Number(totalAmount) || 0;
    if (splitterRatio === "50-30-20") {
      return [
        { label: "Needs (50%) 🏠", amount: amt * 0.50, color: "text-pastel-pink-dark bg-pastel-pink-light/30 border-pastel-pink/20" },
        { label: "Wants (30%) 🛍️", amount: amt * 0.30, color: "text-pastel-coral bg-pastel-salmon/20 border-pastel-salmon/30" },
        { label: "Savings (20%) 🏦", amount: amt * 0.20, color: "text-accent bg-accent/10 border-accent/20" }
      ];
    } else if (splitterRatio === "70-20-10") {
      return [
        { label: "Expenses (70%) 🧾", amount: amt * 0.70, color: "text-pastel-pink-dark bg-pastel-pink-light/30 border-pastel-pink/20" },
        { label: "Savings (20%) 💰", amount: amt * 0.20, color: "text-pastel-coral bg-pastel-salmon/20 border-pastel-salmon/30" },
        { label: "Fun Play (10%) 🎟️", amount: amt * 0.10, color: "text-accent bg-accent/10 border-accent/20" }
      ];
    } else {
      return [
        { label: "Core Living (80%) 🔑", amount: amt * 0.80, color: "text-pastel-pink-dark bg-pastel-pink-light/30 border-pastel-pink/20" },
        { label: "Secure Wealth (20%) 💎", amount: amt * 0.20, color: "text-accent bg-accent/10 border-accent/20" }
      ];
    }
  };

  return (
    <div className="flex flex-col h-full space-y-4">
      {/* Dynamic Header Tab Selector */}
      <div className="flex bg-slate-50 dark:bg-slate-800 p-1 rounded-2xl border border-pastel-salmon/20 shrink-0">
        <button
          onClick={() => setCalcMode("standard")}
          className={`flex-1 py-2 text-xs font-black rounded-xl transition-all cursor-pointer ${calcMode === "standard"
            ? "bg-white dark:bg-slate-700 text-pastel-pink-dark shadow-sm border border-pastel-salmon/10"
            : "text-slate-400 dark:text-slate-500 hover:text-slate-600"
            }`}
        >
          Standard Math 🧮
        </button>
        <button
          onClick={() => setCalcMode("splitter")}
          className={`flex-1 py-2 text-xs font-black rounded-xl transition-all cursor-pointer ${calcMode === "splitter"
            ? "bg-white dark:bg-slate-700 text-pastel-pink-dark shadow-sm border border-pastel-salmon/10"
            : "text-slate-400 dark:text-slate-500 hover:text-slate-600"
            }`}
        >
          Royal Ratio Split 👑
        </button>
      </div>

      <AnimatePresence mode="wait">
        {calcMode === "standard" ? (
          <motion.div
            key="standard"
            initial={{ opacity: 0, y: 15 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -15 }}
            className="flex-grow flex flex-col justify-between"
          >
            {/* Screen Panel */}
            <div className="bg-[#FFF8FA] dark:bg-slate-800 border-2 border-pastel-salmon/20 rounded-[32px] p-6 text-right space-y-2 flex flex-col justify-end min-h-[110px] shadow-inner shadow-pastel-pink/5 relative overflow-hidden">
              <div className="absolute top-3 left-4 text-[9px] font-black text-pastel-pink-dark uppercase tracking-widest flex items-center gap-1 opacity-70">
                <Landmark size={10} /> Pocket Calculator
              </div>
              <div className="text-[11px] font-bold text-slate-400 dark:text-slate-500 font-mono truncate">
                {equation || "0"}
              </div>
              <div className="text-3xl font-black text-slate-800 dark:text-white font-mono tracking-tight truncate">
                {display || "0"}
              </div>
            </div>

            {/* Keypad */}
            <div className="grid grid-cols-4 gap-3 mt-4 flex-grow content-end">
              {/* Row 1 */}
              <button onClick={handleClear} className="h-12 rounded-2xl bg-red-50 dark:bg-red-950/20 text-red-500 font-black text-xs uppercase cursor-pointer hover:opacity-85 active:scale-95 transition-all">
                AC
              </button>
              <button onClick={handleBackspace} className="h-12 rounded-2xl bg-pastel-pink-light/30 dark:bg-slate-800 text-pastel-pink-dark flex items-center justify-center cursor-pointer hover:opacity-85 active:scale-95 transition-all">
                <Delete size={18} />
              </button>
              <button onClick={() => handleKeyPress("%")} className="h-12 rounded-2xl bg-pastel-pink-light/30 dark:bg-slate-800 text-pastel-pink-dark font-black text-sm cursor-pointer hover:opacity-85 active:scale-95 transition-all">
                %
              </button>
              <button onClick={() => handleOperator("/")} className="h-12 rounded-2xl bg-pastel-pink text-white font-black text-lg cursor-pointer hover:bg-pastel-pink-dark active:scale-95 transition-all">
                ÷
              </button>

              {/* Row 2 */}
              {["7", "8", "9"].map((num) => (
                <button
                  key={num}
                  onClick={() => handleKeyPress(num)}
                  className="h-12 rounded-2xl bg-white dark:bg-slate-800 border border-slate-100 dark:border-slate-700/50 text-slate-700 dark:text-slate-300 font-black text-lg font-mono cursor-pointer hover:bg-pastel-pink-light/20 active:scale-95 transition-all"
                >
                  {num}
                </button>
              ))}
              <button onClick={() => handleOperator("*")} className="h-12 rounded-2xl bg-pastel-pink text-white font-black text-lg cursor-pointer hover:bg-pastel-pink-dark active:scale-95 transition-all">
                ×
              </button>

              {/* Row 3 */}
              {["4", "5", "6"].map((num) => (
                <button
                  key={num}
                  onClick={() => handleKeyPress(num)}
                  className="h-12 rounded-2xl bg-white dark:bg-slate-800 border border-slate-100 dark:border-slate-700/50 text-slate-700 dark:text-slate-300 font-black text-lg font-mono cursor-pointer hover:bg-pastel-pink-light/20 active:scale-95 transition-all"
                >
                  {num}
                </button>
              ))}
              <button onClick={() => handleOperator("-")} className="h-12 rounded-2xl bg-pastel-pink text-white font-black text-lg cursor-pointer hover:bg-pastel-pink-dark active:scale-95 transition-all">
                -
              </button>

              {/* Row 4 */}
              {["1", "2", "3"].map((num) => (
                <button
                  key={num}
                  onClick={() => handleKeyPress(num)}
                  className="h-12 rounded-2xl bg-white dark:bg-slate-800 border border-slate-100 dark:border-slate-700/50 text-slate-700 dark:text-slate-300 font-black text-lg font-mono cursor-pointer hover:bg-pastel-pink-light/20 active:scale-95 transition-all"
                >
                  {num}
                </button>
              ))}
              <button onClick={() => handleOperator("+")} className="h-12 rounded-2xl bg-pastel-pink text-white font-black text-lg cursor-pointer hover:bg-pastel-pink-dark active:scale-95 transition-all">
                +
              </button>

              {/* Row 5 */}
              <button onClick={() => handleKeyPress("0")} className="col-span-2 h-12 rounded-2xl bg-white dark:bg-slate-800 border border-slate-100 dark:border-slate-700/50 text-slate-700 dark:text-slate-300 font-black text-lg font-mono cursor-pointer hover:bg-pastel-pink-light/20 active:scale-95 transition-all">
                0
              </button>
              <button onClick={() => handleKeyPress(".")} className="h-12 rounded-2xl bg-white dark:bg-slate-800 border border-slate-100 dark:border-slate-700/50 text-slate-700 dark:text-slate-300 font-black text-lg font-mono cursor-pointer hover:bg-pastel-pink-light/20 active:scale-95 transition-all">
                .
              </button>
              <button onClick={handleEvaluate} className="h-12 rounded-2xl bg-accent text-white font-black text-xl cursor-pointer hover:bg-accent-dark active:scale-95 transition-all shadow-md shadow-accent/20">
                =
              </button>
            </div>
          </motion.div>
        ) : (
          <motion.div
            key="splitter"
            initial={{ opacity: 0, y: 15 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -15 }}
            className="flex-grow flex flex-col justify-between space-y-4"
          >
            {/* Splitter Form */}
            <div className="space-y-3">
              <div>
                <label className="block text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1.5 px-1">Total Budget Amount</label>
                <div className="relative">
                  <span className="absolute left-4 top-4 text-xs font-black text-slate-400 font-mono select-none">₱</span>
                  <input
                    type="number"
                    placeholder="e.g. 10000"
                    className="w-full p-4 pl-8 rounded-2xl bg-[#FFF8FA] dark:bg-slate-800 border-2 border-pastel-salmon/20 focus:border-pastel-coral/50 outline-none transition-all text-slate-700 dark:text-white font-black font-mono text-sm shadow-inner"
                    value={totalAmount}
                    onChange={(e) => setTotalAmount(e.target.value ? Number(e.target.value) : "")}
                  />
                </div>
              </div>

              {/* Ratio Presets */}
              <div>
                <label className="block text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1.5 px-1">Ratio Standard</label>
                <div className="grid grid-cols-3 gap-2">
                  {[
                    { val: "50-30-20", label: "50/30/20" },
                    { val: "70-20-10", label: "70/20/10" },
                    { val: "80-20", label: "80/20" }
                  ].map((preset) => (
                    <button
                      key={preset.val}
                      onClick={() => setSplitterRatio(preset.val as any)}
                      className={`py-2 text-[10px] font-black rounded-xl border transition-all cursor-pointer ${splitterRatio === preset.val
                        ? "bg-pastel-pink border-pastel-pink text-white shadow-sm"
                        : "bg-white dark:bg-slate-800 border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-400 hover:bg-slate-50"
                        }`}
                    >
                      {preset.label}
                    </button>
                  ))}
                </div>
              </div>
            </div>

            {/* Split Results */}
            <div className="flex-grow space-y-3 flex flex-col justify-center min-h-[160px]">
              {calculateSplit().map((item, idx) => (
                <div
                  key={idx}
                  className={`p-3 rounded-2xl border flex justify-between items-center shadow-sm ${item.color}`}
                >
                  <span className="text-[10px] font-black uppercase tracking-wider">{item.label}</span>
                  <span className="text-sm font-black font-mono">₱ {item.amount.toLocaleString()}</span>
                </div>
              ))}
            </div>

            {/* Split Help */}
            <div className="p-3 bg-slate-50 dark:bg-slate-800/50 rounded-2xl border border-dashed border-slate-200 dark:border-slate-700/50 flex gap-2 items-center">
              <HelpCircle size={14} className="text-slate-400 shrink-0" />
              <p className="text-[8px] text-slate-450 dark:text-slate-500 font-bold leading-normal uppercase">
                Split your total sum standardly to budget smart and safeguard wealth effortlessly! 🌸
              </p>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
