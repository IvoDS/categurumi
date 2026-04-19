import { Head, Link } from '@inertiajs/react';
import React, { useState } from 'react';

interface Creation {
    id: number;
    title: string;
    description: string;
    image_path: string;
    created_at: string;
}

interface WelcomeProps {
    creations: Creation[];
}

export default function Welcome({ creations }: WelcomeProps) {
    const [selectedCreation, setSelectedCreation] = useState<Creation | null>(null);

    return (
        <>
            <Head title="CateGurumi - Amigurumi Creations" />

            <div className="min-h-screen bg-brand-bg font-sans text-foreground">
                <header className="py-12 text-center">
                    <h1 className="text-5xl font-bold text-primary mb-2">CateGurumi</h1>
                    <p className="text-xl text-secondary">Le creazioni di Caterina</p>
                </header>

                <main className="max-w-7xl mx-auto px-4 pb-20">
                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
                        {creations.map((creation) => (
                            <div
                                key={creation.id}
                                className="group bg-white rounded-3xl overflow-hidden shadow-lg cursor-pointer transform transition duration-300 hover:scale-105"
                                onClick={() => setSelectedCreation(creation)}
                            >
                                <div className="aspect-square overflow-hidden relative">
                                    <img
                                        src={`/storage/${creation.image_path}`}
                                        alt={creation.title}
                                        className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
                                        loading="lazy"
                                    />
                                    <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-20 transition-opacity duration-300 flex items-center justify-center">
                                        <span className="text-white opacity-0 group-hover:opacity-100 font-semibold text-lg bg-primary px-4 py-2 rounded-full shadow-md">
                                            Vedi dettagli
                                        </span>
                                    </div>
                                </div>
                                <div className="p-6">
                                    <h3 className="text-2xl font-bold text-primary truncate">{creation.title}</h3>
                                    <p className="text-secondary mt-1 truncate">{creation.description}</p>
                                </div>
                            </div>
                        ))}
                    </div>

                    {creations.length === 0 && (
                        <div className="text-center py-20 bg-white rounded-3xl shadow-inner border-2 border-dashed border-secondary/30">
                            <p className="text-2xl text-secondary font-medium italic">Nessuna creazione ancora disponibile. Torna presto!</p>
                        </div>
                    )}
                </main>

                <footer className="py-8 text-center border-t border-primary/10">
                    <p className="text-secondary opacity-70">© {new Date().getFullYear()} CateGurumi - Fatto con amore ❤️</p>
                    <Link 
                        href="/admin/login" 
                        className="text-[10px] text-secondary opacity-30 hover:opacity-100 mt-4 inline-block transition-opacity"
                    >
                        Area Riservata
                    </Link>
                </footer>

                {/* Modal */}
                {selectedCreation && (
                    <div
                        className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 bg-black/60 backdrop-blur-sm transition-opacity duration-300"
                        onClick={() => setSelectedCreation(null)}
                    >
                        <div
                            className="bg-white rounded-[2rem] overflow-hidden max-w-4xl w-full max-h-[90vh] flex flex-col sm:flex-row shadow-2xl animate-in zoom-in duration-300"
                            onClick={(e) => e.stopPropagation()}
                        >
                            <div className="sm:w-3/5 bg-accent-light relative">
                                <img
                                    src={`/storage/${selectedCreation.image_path}`}
                                    alt={selectedCreation.title}
                                    className="w-full h-full object-contain max-h-[50vh] sm:max-h-none"
                                />
                                <button
                                    className="absolute top-4 right-4 bg-white/80 hover:bg-white text-primary rounded-full p-2 shadow-lg transition-colors sm:hidden"
                                    onClick={() => setSelectedCreation(null)}
                                >
                                    <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                                    </svg>
                                </button>
                            </div>
                            <div className="sm:w-2/5 p-8 sm:p-10 flex flex-col justify-between overflow-y-auto">
                                <div>
                                    <div className="flex justify-between items-start mb-6">
                                        <h2 className="text-4xl font-bold text-primary leading-tight">{selectedCreation.title}</h2>
                                        <button
                                            className="hidden sm:block text-secondary hover:text-primary transition-colors"
                                            onClick={() => setSelectedCreation(null)}
                                        >
                                            <svg xmlns="http://www.w3.org/2000/svg" className="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                                            </svg>
                                        </button>
                                    </div>
                                    <p className="text-lg text-gray-700 leading-relaxed whitespace-pre-wrap">{selectedCreation.description}</p>
                                </div>
                                <div className="mt-10">
                                    <button
                                        className="w-full bg-primary hover:bg-secondary text-white font-bold py-4 px-6 rounded-2xl shadow-lg transition-all transform hover:-translate-y-1 active:scale-95"
                                        onClick={() => setSelectedCreation(null)}
                                    >
                                        Chiudi
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                )}
            </div>
        </>
    );
}
