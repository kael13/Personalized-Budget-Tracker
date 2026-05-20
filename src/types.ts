export interface SubCategory {
  id: string;
  name: string;
  allocatedAmount: number;
  spentAmount: number;
}

export interface Category {
  id: string;
  name: string;
  allocatedAmount: number;
  spentAmount: number;
  subCategories: SubCategory[];
}

export interface BudgetAllocation {
  id: string;
  name: string;
  totalBudget: number;
  currency: string;
  daysToConsume: number;
  createdAt: string;
  pin: string | null; // 6-digit PIN for privacy
  categories: Category[];
}

export interface AppConfig {
  darkMode: boolean;
}
