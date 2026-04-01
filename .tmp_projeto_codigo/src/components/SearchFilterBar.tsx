import { useState } from "react";
import { Filter, ArrowDownUp, Sparkles, Search } from "lucide-react";

const SearchFilterBar = () => {
  const [searchOpen, setSearchOpen] = useState(false);
  const [query, setQuery] = useState("");

  return (
    <div className="flex items-center gap-2 px-4 py-2">
      <button className="w-8 h-8 flex items-center justify-center text-foreground/70 hover:text-foreground transition-colors">
        <Filter className="w-4 h-4" />
      </button>
      <button className="w-8 h-8 flex items-center justify-center text-foreground/70 hover:text-foreground transition-colors">
        <ArrowDownUp className="w-4 h-4" />
      </button>
      <button className="w-8 h-8 flex items-center justify-center text-foreground/70 hover:text-foreground transition-colors">
        <Sparkles className="w-4 h-4" />
      </button>

      <div className="flex-1 flex items-center glass rounded-full px-3 py-1.5">
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Buscar..."
          className="flex-1 bg-transparent text-sm outline-none placeholder:text-muted-foreground text-foreground"
        />
        <Search className="w-4 h-4 text-foreground/70" />
      </div>
    </div>
  );
};

export default SearchFilterBar;
