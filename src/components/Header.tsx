import React from "react";
import { Sun, Moon } from "lucide-react";

interface HeaderProps {
  darkMode: boolean;
  toggleDarkMode: () => void;
}

export default function Header({ darkMode, toggleDarkMode }: HeaderProps) {
  return (
    <header className="hidden xl:flex w-full h-16 bg-white/80 dark:bg-slate-900/80 backdrop-blur-md border-b border-pastel-pink/20 flex items-center justify-between px-6 xl:px-8 shrink-0 z-50 transition-colors">
      <div className="flex items-center gap-3">
        <div className="w-9 h-9 bg-pastel-pink rounded-full flex items-center justify-center shadow-sm">
          <span className="text-white font-black text-lg">B</span>
        </div>
        <h1 className="text-lg xl:text-xl font-bold text-pastel-pink-dark tracking-tight">BloomBudget</h1>
      </div>
      
      <div className="flex items-center gap-4 xl:gap-6">
        <div className="hidden sm:flex bg-pastel-pink-light dark:bg-slate-800 p-1 rounded-full border border-pastel-pink/20">
          <button 
            onClick={() => darkMode && toggleDarkMode()}
            className={`px-4 py-1.5 rounded-full text-[10px] font-black transition-all ${!darkMode ? 'bg-white text-pastel-pink-dark shadow-sm' : 'text-slate-400 opacity-60'}`}
          >
            LIGHT
          </button>
          <button 
            onClick={() => !darkMode && toggleDarkMode()}
            className={`px-4 py-1.5 rounded-full text-[10px] font-black transition-all ${darkMode ? 'bg-slate-700 text-pastel-pink shadow-sm' : 'text-slate-500 opacity-60'}`}
          >
            DARK
          </button>
        </div>
        
        <button 
          onClick={toggleDarkMode}
          className="sm:hidden w-9 h-9 bg-white dark:bg-slate-800 text-pastel-pink rounded-full flex items-center justify-center shadow-sm border border-pastel-pink/10"
        >
          {darkMode ? <Sun size={18} /> : <Moon size={18} />}
        </button>

        <div className="w-9 h-9 bg-pastel-pink-light border-2 border-pastel-pink rounded-full flex items-center justify-center overflow-hidden">
          <img src={`https://api.dicebear.com/7.x/adventurer/svg?seed=${darkMode ? 'night' : 'pink'}`} alt="avatar" className="w-full h-full" />
        </div>
      </div>
    </header>
  );
}
