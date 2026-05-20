import React from "react";
import { PieChart as PieChartIcon } from "lucide-react";
import { 
  PieChart, 
  Pie, 
  Cell, 
  ResponsiveContainer, 
  Tooltip as RechartsTooltip, 
  Legend 
} from "recharts";

interface CategoryData {
  name: string;
  value: number;
}

interface GlobalAnalyticsProps {
  globalCategoryData: CategoryData[];
  chartColors: string[];
}

export default function GlobalAnalytics({
  globalCategoryData,
  chartColors,
}: GlobalAnalyticsProps) {
  const dataSlice = globalCategoryData.slice(0, 8);

  if (globalCategoryData.length === 0) return null;

  return (
    <div className="bg-white dark:bg-slate-900 rounded-[32px] p-8 border border-pastel-pink/10 shadow-sm shrink-0 transition-colors">
      <div className="flex justify-between items-center mb-6">
        <div className="flex items-center gap-2">
          <PieChartIcon className="text-pastel-pink-dark" />
          <h3 className="text-sm font-black text-slate-800 dark:text-white uppercase tracking-[0.2em]">Global Category Breakdown</h3>
        </div>
        <div className="text-[10px] font-black text-slate-400 uppercase tracking-widest bg-slate-50 dark:bg-slate-800 px-3 py-1 rounded-full">
          Top {dataSlice.length} Categories
        </div>
      </div>
      <div className="h-48 w-full">
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie
              data={dataSlice}
              cx="50%"
              cy="50%"
              innerRadius={60}
              outerRadius={80}
              paddingAngle={5}
              dataKey="value"
            >
              {dataSlice.map((entry, index) => (
                <Cell key={`cell-${index}`} fill={chartColors[index % chartColors.length]} />
              ))}
            </Pie>
            <RechartsTooltip 
              contentStyle={{ 
                borderRadius: '16px', 
                border: 'none', 
                boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)', 
                fontSize: '10px', 
                fontWeight: 'bold' 
              }}
            />
            <Legend 
              verticalAlign="middle" 
              align="right"
              layout="vertical"
              formatter={(value) => (
                <span className="text-[10px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-tight">
                  {value}
                </span>
              )}
            />
          </PieChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
