import { motion } from "framer-motion";
import { Pencil, Lightbulb } from "lucide-react";

type NavTab = "projects" | "ideas";

interface BottomNavBarProps {
  activeTab: NavTab;
  onTabSelect: (tab: NavTab) => void;
}

const BottomNavBar = ({ activeTab, onTabSelect }: BottomNavBarProps) => {
  return (
    <div className="glass-strong rounded-t-2xl flex overflow-hidden">
      <button
        onClick={() => onTabSelect("projects")}
        className={`flex-1 flex items-center justify-center gap-2 py-4 transition-all duration-200 ${
          activeTab === "projects"
            ? "text-foreground"
            : "text-muted-foreground opacity-50"
        }`}
      >
        <Pencil className="w-5 h-5" />
        <span className="font-medium text-sm">Projetos</span>
        {activeTab === "projects" && (
          <motion.div
            layoutId="nav-indicator"
            className="absolute bottom-1 h-0.5 w-12 bg-primary rounded-full"
          />
        )}
      </button>
      <button
        onClick={() => onTabSelect("ideas")}
        className={`flex-1 flex items-center justify-center gap-2 py-4 transition-all duration-200 ${
          activeTab === "ideas"
            ? "text-foreground"
            : "text-muted-foreground opacity-50"
        }`}
      >
        <Lightbulb className="w-5 h-5" />
        <span className="font-medium text-sm">Ideias</span>
        {activeTab === "ideas" && (
          <motion.div
            layoutId="nav-indicator"
            className="absolute bottom-1 h-0.5 w-12 bg-primary rounded-full"
          />
        )}
      </button>
    </div>
  );
};

export default BottomNavBar;
