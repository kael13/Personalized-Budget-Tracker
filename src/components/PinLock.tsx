import React, { useState, useEffect } from "react";
import { motion, AnimatePresence } from "motion/react";
import { Shield, X, Delete } from "lucide-react";

interface PinLockProps {
  correctPin: string;
  onSuccess: () => void;
  onCancel: () => void;
}

export default function PinLock({ correctPin, onSuccess, onCancel }: PinLockProps) {
  const [pin, setPin] = useState("");
  const [error, setError] = useState(false);

  useEffect(() => {
    if (pin.length === 6) {
      if (pin === correctPin) {
        onSuccess();
      } else {
        setError(true);
        setTimeout(() => {
          setPin("");
          setError(false);
        }, 800);
      }
    }
  }, [pin, correctPin, onSuccess]);

  const handlePress = (num: string) => {
    if (pin.length < 6) setPin(pin + num);
  };

  const handleBackspace = () => {
    setPin(pin.slice(0, -1));
  };

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-[100] bg-white dark:bg-slate-900 flex flex-col items-center justify-center p-8"
    >
      <div className="absolute top-12 right-8">
        <button onClick={onCancel} className="p-3 bg-pastel-pink-light dark:bg-slate-800 text-pastel-pink rounded-full hover:bg-pastel-pink hover:text-white transition-all shadow-sm">
          <X size={24} />
        </button>
      </div>

      <div className="text-center mb-12">
        <div className={`w-20 h-20 bg-pastel-pink-light rounded-full flex items-center justify-center mx-auto mb-6 text-pastel-pink transition-all duration-300 ${error ? 'bg-red-100 text-red-400 scale-110' : ''}`}>
          <Shield size={40} />
        </div>
        <h2 className="text-2xl font-black text-slate-800 dark:text-white mb-2">Locked Budget</h2>
        <p className="text-sm font-bold text-slate-400">Enter your 6-digit royal PIN ✨</p>
      </div>

      {/* Pin Dots */}
      <div className="flex gap-4 mb-16">
        {[...Array(6)].map((_, i) => (
          <motion.div
            key={i}
            animate={error ? { x: [0, -10, 10, -10, 10, 0] } : {}}
            className={`w-4 h-4 rounded-full border-2 transition-all duration-200 ${
              pin.length > i 
                ? "bg-pastel-pink border-pastel-pink scale-125" 
                : "bg-transparent border-slate-200 dark:border-slate-700"
            }`}
          />
        ))}
      </div>

      {/* Keypad */}
      <div className="grid grid-cols-3 gap-6 w-full max-w-[300px]">
        {["1", "2", "3", "4", "5", "6", "7", "8", "9", "", "0", "back"].map((key, i) => (
            <button
              key={i}
              onClick={() => key === "back" ? handleBackspace() : key ? handlePress(key) : null}
              className={`w-16 h-16 sm:w-20 sm:h-20 flex items-center justify-center rounded-full text-2xl font-black font-mono transition-all active:scale-90 ${
                !key 
                  ? "pointer-events-none" 
                  : key === "back" 
                    ? "text-pastel-pink-dark/40" 
                    : "bg-pastel-pink-light/50 dark:bg-slate-800 text-slate-700 dark:text-slate-300 hover:bg-pastel-pink/20"
              }`}
            >
            {key === "back" ? <Delete /> : key}
          </button>
        ))}
      </div>
    </motion.div>
  );
}
