import { useState, useEffect } from "react";
import type { BudgetAllocation, AppConfig } from "../types";
import { db } from "../services/db";

export function useBudgetTracker() {
  const [budgets, setBudgets] = useState<BudgetAllocation[]>([]);
  const [config, setConfig] = useState<AppConfig>({ darkMode: false });
  const [activeTab, setActiveTab] = useState<"dashboard" | "analytics" | "calculator">("dashboard");
  const [showNewModal, setShowNewModal] = useState(false);
  const [selectedBudget, setSelectedBudget] = useState<BudgetAllocation | null>(null);
  const [editingBudget, setEditingBudget] = useState<BudgetAllocation | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [sortBy, setSortBy] = useState<"date" | "amount">("date");

  useEffect(() => {
    const initData = async () => {
      const savedBudgets = await db.getBudgets();
      setBudgets(savedBudgets);
      
      const savedConfig = localStorage.getItem("config");
      if (savedConfig) setConfig(JSON.parse(savedConfig));
    };
    initData();
  }, []);

  useEffect(() => {
    if (config.darkMode) {
      document.documentElement.classList.add("dark");
    } else {
      document.documentElement.classList.remove("dark");
    }
  }, [config.darkMode]);

  const handleCreateBudget = async (budget: BudgetAllocation) => {
    await db.saveBudget(budget);
    const updated = await db.getBudgets();
    setBudgets(updated);
    setShowNewModal(false);
    setEditingBudget(null);
  };

  const handleUpdateBudget = async (budget: BudgetAllocation) => {
    await db.saveBudget(budget);
    const updated = await db.getBudgets();
    setBudgets(updated);
    if (selectedBudget?.id === budget.id) {
      setSelectedBudget(budget);
    }
  };


  const handleDeleteBudget = async (id: string) => {
    if (window.confirm("Are you sure you want to delete this budget profile? ✨")) {
      await db.deleteBudget(id);
      const updated = await db.getBudgets();
      setBudgets(updated);
      setSelectedBudget(null);
    }
  };

  const handleDeleteMultipleBudgets = async (ids: string[]) => {
    if (window.confirm(`Are you sure you want to delete the selected ${ids.length} budget profiles? ✨`)) {
      for (const id of ids) {
        await db.deleteBudget(id);
      }
      const updated = await db.getBudgets();
      setBudgets(updated);
      setSelectedBudget(null);
    }
  };

  const handleBudgetClick = (budget: BudgetAllocation) => {
    setSelectedBudget(budget);
  };

  const toggleDarkMode = () => {
    const newConfig = { ...config, darkMode: !config.darkMode };
    setConfig(newConfig);
    localStorage.setItem("config", JSON.stringify(newConfig));
  };

  const getGlobalCategoryData = () => {
    const data: Record<string, number> = {};
    budgets.forEach((b) => {
      b.categories.forEach((c) => {
        const name = c.name || "Other";
        data[name] = (data[name] || 0) + c.allocatedAmount;
      });
    });
    return Object.entries(data)
      .sort((a, b) => b[1] - a[1])
      .map(([name, value]) => ({ name, value }));
  };

  const filteredBudgets = budgets
    .filter((b) => b.name.toLowerCase().includes(searchQuery.toLowerCase()))
    .sort((a, b) => {
      // Pin to top first!
      const aPinned = !!a.pin;
      const bPinned = !!b.pin;
      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;

      if (sortBy === "date") return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime();
      return b.totalBudget - a.totalBudget;
    });

  const totalBudgetAmount = budgets.reduce((acc, b) => acc + b.totalBudget, 0);
  const maxDaysToConsume = budgets.length > 0 ? Math.max(...budgets.map((b) => b.daysToConsume)) : 0;
  const globalCategoryData = getGlobalCategoryData();

  return {
    budgets,
    config,
    activeTab,
    setActiveTab,
    showNewModal,
    setShowNewModal,
    selectedBudget,
    setSelectedBudget,
    editingBudget,
    setEditingBudget,
    searchQuery,
    setSearchQuery,
    sortBy,
    setSortBy,
    handleCreateBudget,
    handleUpdateBudget,
    handleDeleteBudget,
    handleDeleteMultipleBudgets,
    handleBudgetClick,
    toggleDarkMode,
    filteredBudgets,
    totalBudgetAmount,
    maxDaysToConsume,
    globalCategoryData,
  };
}
