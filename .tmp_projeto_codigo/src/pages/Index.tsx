import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Plus } from "lucide-react";
import bgGradient from "@/assets/bg-gradient.jpg";
import MainHeader from "@/components/MainHeader";
import SearchFilterBar from "@/components/SearchFilterBar";
import ProjectCard from "@/components/ProjectCard";
import IdeasContent from "@/components/IdeasContent";
import BottomNavBar from "@/components/BottomNavBar";

const mockProjects = [
  {
    title: "Projeto 1",
    synopsis: "Uma história épica sobre coragem e redenção em um mundo devastado pela guerra.",
    tags: ["Fantasia", "Épico"],
    lastModified: "20/03/2026 09:15",
    timeAgo: "6 dias",
  },
  {
    title: "Projeto 2",
    synopsis: "Conto curto explorando a solidão urbana e conexões inesperadas.",
    tags: ["Contemporâneo", "Drama"],
    lastModified: "18/03/2026 16:42",
    timeAgo: "1 semana",
  },
  {
    title: "Projeto 3",
    synopsis: "Thriller psicológico ambientado em uma cidade costeira isolada.",
    tags: ["Suspense"],
    lastModified: "10/03/2026 11:00",
    timeAgo: "2 semanas",
  },
  {
    title: "Projeto 4",
    synopsis: "Lorem ipsum dolor sit amet consectetur adipiscing elit. Quisque faucibus ex sapien vitae pellentesque sem placerat. In id cursus mi pretium tellus duis convallis. Tempus leo eu aenean sed diam urna tempor. Pulvinar vivamus fringilla lacus nec metus bibendum egestas. Iaculis massa nisl malesuada lacinia integer nunc posuere.",
    tags: ["Tag 1", "Tag 2"],
    lastModified: "15/03/2026 14:30",
    timeAgo: "1 semana",
  },
];

type NavTab = "projects" | "ideas";

const Index = () => {
  const [activeTab, setActiveTab] = useState<NavTab>("projects");

  return (
    <div className="relative min-h-screen max-w-lg mx-auto flex flex-col overflow-hidden">
      {/* Background */}
      <div className="fixed inset-0 -z-10">
        <img
          src={bgGradient}
          alt=""
          className="w-full h-full object-cover opacity-40"
          width={768}
          height={1536}
        />
        <div className="absolute inset-0 bg-gradient-to-b from-transparent via-background/60 to-background" />
      </div>

      {/* Header */}
      <MainHeader title="WIREFRAME" />

      {/* Search/Filter */}
      <SearchFilterBar />

      {/* Content area */}
      <div className="flex-1 overflow-y-auto pb-24">
        <AnimatePresence mode="wait">
          {activeTab === "projects" ? (
            <motion.div
              key="projects"
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              transition={{ duration: 0.25 }}
              className="px-4 space-y-4 py-2"
            >
              {mockProjects.map((project) => (
                <ProjectCard key={project.title} {...project} />
              ))}
            </motion.div>
          ) : (
            <motion.div
              key="ideas"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 20 }}
              transition={{ duration: 0.25 }}
              className="py-2"
            >
              <IdeasContent />
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {/* FAB */}
      <button className="fixed bottom-24 right-6 w-14 h-14 rounded-full bg-primary text-primary-foreground shadow-lg flex items-center justify-center hover:scale-105 active:scale-95 transition-transform z-10">
        <Plus className="w-6 h-6" />
      </button>

      {/* Bottom Nav */}
      <div className="fixed bottom-0 left-0 right-0 max-w-lg mx-auto z-10">
        <BottomNavBar activeTab={activeTab} onTabSelect={setActiveTab} />
      </div>
    </div>
  );
};

export default Index;
