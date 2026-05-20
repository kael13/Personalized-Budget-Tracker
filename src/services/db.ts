import { BudgetAllocation, Category, SubCategory } from "../types";

/**
 * DATABASE SCHEMA RECOMMENDATION FOR SQLITE (iOS):
 * 
 * -- Table: budgets
 * CREATE TABLE budgets (
 *   id TEXT PRIMARY KEY,
 *   name TEXT NOT NULL,
 *   total_budget REAL NOT NULL,
 *   currency TEXT NOT NULL,
 *   days_to_consume INTEGER NOT NULL,
 *   created_at TEXT NOT NULL,
 *   pin TEXT
 * );
 * 
 * -- Table: categories
 * CREATE TABLE categories (
 *   id TEXT PRIMARY KEY,
 *   budget_id TEXT NOT NULL,
 *   name TEXT NOT NULL,
 *   allocated_amount REAL NOT NULL,
 *   spent_amount REAL NOT NULL,
 *   FOREIGN KEY (budget_id) REFERENCES budgets (id) ON DELETE CASCADE
 * );
 * 
 * -- Table: sub_categories
 * CREATE TABLE sub_categories (
 *   id TEXT PRIMARY KEY,
 *   category_id TEXT NOT NULL,
 *   name TEXT NOT NULL,
 *   allocated_amount REAL NOT NULL,
 *   spent_amount REAL NOT NULL,
 *   FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
 * );
 */

// Simulation of Local Storage for Web Development
const STORAGE_KEY = "bloom_budget_db";

export const db = {
  // Sync all budgets with LocalStorage (Simulating a database)
  getBudgets: async (): Promise<BudgetAllocation[]> => {
    const data = localStorage.getItem(STORAGE_KEY);
    return data ? JSON.parse(data) : [];
  },

  saveBudget: async (budget: BudgetAllocation): Promise<void> => {
    const budgets = await db.getBudgets();
    const index = budgets.findIndex((b) => b.id === budget.id);

    if (index !== -1) {
      budgets[index] = budget;
    } else {
      budgets.unshift(budget);
    }

    localStorage.setItem(STORAGE_KEY, JSON.stringify(budgets));
  },

  deleteBudget: async (id: string): Promise<void> => {
    const budgets = await db.getBudgets();
    const filtered = budgets.filter((b) => b.id !== id);
    localStorage.setItem(STORAGE_KEY, JSON.stringify(filtered));
  },

  generateId: () => {
    return typeof crypto !== 'undefined' && crypto.randomUUID
      ? crypto.randomUUID()
      : Math.random().toString(36).substring(2, 15);
  }
};
