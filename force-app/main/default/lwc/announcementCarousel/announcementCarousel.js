import { LightningElement } from 'lwc';

export default class AnnouncementCarousel extends LightningElement {
    slides = [
        {
            id: 'slide-1',
            href: 'https://nationaldppcsc.cdc.gov/s/article/in-person-discovery-session-guide',
            img: '/resource/1737063718000/DiscoverySessionInPerson?',
            alt: 'Discovery Session for in person delivery',
            title: 'Discovery Session for in person delivery',
            indicatorLabel: 'Show slide 1: Discovery Session for in person delivery'
        },
        {
            id: 'slide-2',
            href: 'https://nationaldppcsc.cdc.gov/s/article/Session-Zero-Guide-for-Live-Videoconferencing',
            img: '/resource/1737419531000/DiscoverySession_Videoconferencing?',
            alt: 'Discovery Session for videoconferencing',
            title: 'Discovery Session for videoconferencing',
            indicatorLabel: 'Show slide 2: Discovery Session for videoconferencing'
        }
    ];

    currentIndex = 0;
    intervalId;

    connectedCallback() {
        this.startAutoAdvance();
    }

    disconnectedCallback() {
        this.stopAutoAdvance();
    }

    startAutoAdvance() {
        this.intervalId = setInterval(() => {
            this.nextSlide();
        }, 5000); // Change slide every 5 seconds
    }

    stopAutoAdvance() {
        if (this.intervalId) {
            clearInterval(this.intervalId);
            this.intervalId = null;
        }
    }

    nextSlide() {
        this.currentIndex = (this.currentIndex + 1) % this.slides.length;
    }

    goToSlide(event) {
        const idx = Number(event.target.dataset.index);
        this.currentIndex = idx;
        this.stopAutoAdvance();
        this.startAutoAdvance();
    }

    get computedSlides() {
        return this.slides.map((slide, idx) => ({
            ...slide,
            isActive: idx === this.currentIndex,
            ariaHidden: idx === this.currentIndex ? 'false' : 'true',
            indicatorId: `indicator-${idx + 1}`,
            tabIndex: idx === this.currentIndex ? "0" : "-1"
        }));
    }
}