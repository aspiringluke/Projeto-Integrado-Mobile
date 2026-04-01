import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Clock, Edit2, ChevronRight } from "lucide-react";

interface ProjectCardProps {
  title: string;
  imageUrl?: string;
  synopsis?: string;
  tags?: string[];
  lastModified?: string;
  timeAgo?: string;
}

const ProjectCard = ({
  title,
  imageUrl,
  synopsis = "Lorem ipsum dolor sit amet consectetur adipiscing elit. Quisque faucibus ex sapien vitae pellentesque sem placerat.",
  tags = ["Tag 1", "Tag 2"],
  lastModified = "15/03/2026 14:30",
  timeAgo = "1 semana",
}: ProjectCardProps) => {
  const [isExpanded, setIsExpanded] = useState(false);
  const [dateMode, setDateMode] = useState<"modified" | "accessed" | "created">("modified");

  const dateLabels = {
    modified: "Última Modificação",
    accessed: "Último Acesso",
    created: "Criado em",
  };

  const cycleDateMode = () => {
    setDateMode((prev) =>
      prev === "modified" ? "accessed" : prev === "accessed" ? "created" : "modified"
    );
  };

  return (
    <motion.div
      layout
      className="glass-card rounded-lg overflow-hidden"
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3 }}
    >
      {/* Header */}
      <div
        className="relative flex items-center gap-3 p-3 cursor-pointer"
        onClick={() => setIsExpanded(!isExpanded)}
      >
        {/* Project image area */}
        <div className="w-16 h-16 rounded-md overflow-hidden bg-muted flex-shrink-0 flex items-center justify-center">
          {imageUrl ? (
            <img src={imageUrl} alt={title} className="w-full h-full object-cover" />
          ) : (
            <svg className="w-6 h-6 text-muted-foreground opacity-40" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
              <path d="M9.5 9.5l-1 6.5L12 13l3.5 3L14.5 9.5 18 7l-6-.5L9.5 1 7 6.5 1 7l5.5 2.5z" />
            </svg>
          )}
        </div>

        {/* Title */}
        <h3 className="font-display text-2xl tracking-wider text-foreground flex-1">
          {title}
        </h3>

        {/* Expand toggle */}
        <span className="text-sm text-muted-foreground">
          {isExpanded ? "Ver menos..." : "Ver mais..."}
        </span>
      </div>

      {/* Expanded content */}
      <AnimatePresence>
        {isExpanded && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: "auto", opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.3, ease: "easeInOut" }}
            className="overflow-hidden"
          >
            <div className="px-4 pb-4 space-y-3">
              {/* Date row */}
              <div className="flex items-center gap-2 text-sm text-muted-foreground">
                <button
                  onClick={(e) => { e.stopPropagation(); cycleDateMode(); }}
                  className="w-7 h-7 rounded-full bg-muted flex items-center justify-center hover:bg-primary/10 transition-colors"
                >
                  <Clock className="w-3.5 h-3.5" />
                </button>
                <span>
                  {dateLabels[dateMode]}: {lastModified}, há {timeAgo} atrás.
                </span>
                <button className="ml-auto w-7 h-7 rounded-full bg-muted flex items-center justify-center hover:bg-primary/10 transition-colors">
                  <Edit2 className="w-3.5 h-3.5" />
                </button>
              </div>

              {/* Synopsis */}
              <div className="relative bg-card rounded-md p-3 max-h-36 overflow-y-auto scrollbar-thin">
                <p className="text-sm leading-relaxed italic text-foreground/80">{synopsis}</p>
              </div>

              {/* Tags */}
              <div className="flex items-center gap-2 flex-wrap">
                {tags.map((tag, i) => (
                  <span
                    key={tag}
                    className={`px-3 py-1 rounded-full text-xs font-medium border ${
                      i % 2 === 0
                        ? "border-tag-pink text-tag-pink"
                        : "border-tag-blue text-tag-blue"
                    }`}
                  >
                    {tag}
                  </span>
                ))}
              </div>

              {/* Footer: character avatars + switch pages */}
              <div className="flex items-center justify-between pt-1">
                <div className="flex -space-x-2">
                  {[0, 1, 2].map((i) => (
                    <div
                      key={i}
                      className="w-8 h-8 rounded-full bg-gray-soft border-2 border-card"
                    />
                  ))}
                </div>
                <button className="text-muted-foreground hover:text-foreground transition-colors">
                  <ChevronRight className="w-5 h-5" />
                </button>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
};

export default ProjectCard;
