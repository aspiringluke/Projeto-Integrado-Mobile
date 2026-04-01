import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Folder, FileText, Workflow, Network } from "lucide-react";

const IdeasContent = () => {
  const [view, setView] = useState<"notes" | "diagrams">("notes");

  return (
    <div className="space-y-4">
      {/* Toggle buttons */}
      <div className="flex gap-2 px-4">
        <button
          onClick={() => setView("notes")}
          className={`flex-1 py-2.5 rounded-lg text-sm font-medium transition-all duration-200 ${
            view === "notes"
              ? "glass-strong text-foreground shadow-sm"
              : "text-muted-foreground hover:text-foreground"
          }`}
        >
          Notas
        </button>
        <button
          onClick={() => setView("diagrams")}
          className={`flex-1 py-2.5 rounded-lg text-sm font-medium transition-all duration-200 ${
            view === "diagrams"
              ? "glass-strong text-foreground shadow-sm"
              : "text-muted-foreground hover:text-foreground"
          }`}
        >
          Diagramas
        </button>
      </div>

      {/* Content */}
      <AnimatePresence mode="wait">
        {view === "notes" ? (
          <motion.div
            key="notes"
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -8 }}
            transition={{ duration: 0.2 }}
            className="px-4 space-y-3"
          >
            <h3 className="text-sm font-medium text-muted-foreground">Notas recentes</h3>
            {[
              { title: "Referências visuais", icon: Folder, count: 5 },
              { title: "Arcos narrativos", icon: FileText, count: 3 },
              { title: "Worldbuilding", icon: Folder, count: 8 },
              { title: "Diálogos pendentes", icon: FileText, count: 2 },
            ].map((item) => (
              <div
                key={item.title}
                className="glass-card rounded-lg p-3 flex items-center gap-3 cursor-pointer hover:shadow-md transition-shadow"
              >
                <div className="w-9 h-9 rounded-md bg-muted flex items-center justify-center">
                  <item.icon className="w-4 h-4 text-muted-foreground" />
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium text-foreground">{item.title}</p>
                  <p className="text-xs text-muted-foreground">{item.count} itens</p>
                </div>
              </div>
            ))}
          </motion.div>
        ) : (
          <motion.div
            key="diagrams"
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -8 }}
            transition={{ duration: 0.2 }}
            className="px-4 space-y-3"
          >
            <h3 className="text-sm font-medium text-muted-foreground">Grupos de diagramas</h3>
            {[
              { title: "Linha do Tempo Principal", subtitle: "12 eventos", chips: ["Ato 1", "Ato 2", "Ato 3"], icon: Workflow },
              { title: "Árvore de Personagens", subtitle: "8 conexões", chips: ["Família", "Aliados"], icon: Network },
              { title: "Mapa de Conflitos", subtitle: "5 nós", chips: ["Interno", "Externo"], icon: Workflow },
            ].map((item) => (
              <div
                key={item.title}
                className="glass-card rounded-lg p-4 space-y-2 cursor-pointer hover:shadow-md transition-shadow"
              >
                <div className="flex items-center gap-2">
                  <item.icon className="w-4 h-4 text-primary" />
                  <p className="text-sm font-medium text-foreground">{item.title}</p>
                </div>
                <p className="text-xs text-muted-foreground">{item.subtitle}</p>
                <div className="flex gap-1.5">
                  {item.chips.map((chip) => (
                    <span
                      key={chip}
                      className="px-2 py-0.5 rounded-full text-[10px] bg-muted text-muted-foreground"
                    >
                      {chip}
                    </span>
                  ))}
                </div>
              </div>
            ))}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};

export default IdeasContent;
