import { ChevronLeft, Settings } from "lucide-react";

interface MainHeaderProps {
  title: string;
  subtitle?: string;
  onBack?: () => void;
  onSettings?: () => void;
}

const MainHeader = ({ title, subtitle, onBack, onSettings }: MainHeaderProps) => {
  return (
    <div className="relative flex items-center justify-between px-4 py-6">
      <button
        onClick={onBack}
        className="w-10 h-10 rounded-full glass flex items-center justify-center text-foreground/60 hover:text-foreground transition-colors"
      >
        <ChevronLeft className="w-5 h-5" />
      </button>

      <div className="text-center flex-1">
        <h1 className="font-display text-3xl md:text-4xl tracking-[0.2em] text-foreground">
          {title}
        </h1>
        {subtitle && (
          <p className="text-xs text-muted-foreground mt-0.5">...{subtitle}...</p>
        )}
      </div>

      <button
        onClick={onSettings}
        className="w-10 h-10 rounded-full glass flex items-center justify-center text-foreground/60 hover:text-foreground transition-colors"
      >
        <Settings className="w-5 h-5" />
      </button>
    </div>
  );
};

export default MainHeader;
