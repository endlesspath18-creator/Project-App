import React, { useEffect, useState } from 'react';
import { motion } from 'motion/react';
import { SlidersHorizontal, Search, ArrowLeft } from 'lucide-react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { ServiceRepository } from '../../../repositories/repositories';
import { Service } from '../../../models/models';
import { ServiceCard } from '../../../core/widgets/reusable_widgets';

export const ServicesScreen = () => {
    const [searchParams] = useSearchParams();
    const categoryId = searchParams.get('category');
    const [services, setServices] = useState<Service[]>([]);
    const [loading, setLoading] = useState(true);
    const navigate = useNavigate();

    useEffect(() => {
        const repo = new ServiceRepository();
        if (categoryId) {
            repo.fetchByCategory(categoryId).then(data => {
                setServices(data);
                setLoading(false);
            });
        } else {
            repo.fetchAllServices().then(data => {
                setServices(data);
                setLoading(false);
            });
        }
    }, [categoryId]);

    return (
        <div className="pb-24 pt-12">
            <div className="px-6 mb-8 flex items-center gap-4">
                <button onClick={() => navigate(-1)} className="p-3 bg-surface border border-border rounded-xl">
                    <ArrowLeft size={18} />
                </button>
                <div className="flex-1">
                    <h2 className="text-3xl font-black text-primary tracking-tight">
                        {categoryId ? `${categoryId.charAt(0).toUpperCase() + categoryId.slice(1)}` : 'All Services'}
                    </h2>
                </div>
            </div>

            <div className="px-6 mb-8">
                <div className="relative group">
                    <Search size={18} className="absolute left-5 top-1/2 -translate-y-1/2 text-slate-400" />
                    <input 
                        type="text" 
                        placeholder="Search for service..."
                        className="w-full bg-surface border border-border py-4 pl-14 pr-4 rounded-2xl text-sm font-bold outline-none focus:border-accent"
                    />
                </div>
            </div>

            <div className="px-6 space-y-6">
                {loading ? (
                    [1,2,3].map(i => <div key={i} className="h-48 w-full bg-surface rounded-[40px] animate-pulse" />)
                ) : services.length > 0 ? (
                    services.map(service => (
                        <ServiceCard 
                            key={service.id} 
                            service={service} 
                            onClick={() => navigate(`/service/${service.id}`)}
                        />
                    ))
                ) : (
                    <div className="p-12 text-center text-slate-400 font-bold">No services found in this category.</div>
                )}
            </div>
        </div>
    );
};
