import { BrowserMultiFormatReader } from '@zxing/browser';
import { useEffect, useRef, useState } from 'react';

type Props = {
  onDetected: (code: string) => void;
};

export function BarcodeScanner({ onDetected }: Props) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let active = true;
    let stream: MediaStream | null = null;
    let controls: { stop: () => void } | undefined;
    let raf = 0;
    const zxing = new BrowserMultiFormatReader();

    const boot = async () => {
      try {
        stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' } });
        if (!videoRef.current) {
          return;
        }
        videoRef.current.srcObject = stream;
        await videoRef.current.play();

        if ('BarcodeDetector' in window) {
          const detector = new (window as Window & { BarcodeDetector: any }).BarcodeDetector({
            formats: ['code_128', 'qr_code', 'ean_13', 'upc_a']
          });
          const scan = async () => {
            if (!active || !videoRef.current) {
              return;
            }
            const barcodes = await detector.detect(videoRef.current);
            if (barcodes.length > 0) {
              onDetected(barcodes[0].rawValue);
            }
            raf = requestAnimationFrame(scan);
          };
          raf = requestAnimationFrame(scan);
          return;
        }

        controls = await zxing.decodeFromVideoDevice(undefined, videoRef.current, (result) => {
        zxing.decodeFromVideoDevice(undefined, videoRef.current, (result) => {
          if (result) {
            onDetected(result.getText());
          }
        });
      } catch (e) {
        setError('Camera scan unavailable. Enter barcode manually.');
      }
    };

    void boot();

    return () => {
      active = false;
      cancelAnimationFrame(raf);
      controls?.stop();
      zxing.reset();
      stream?.getTracks().forEach((track) => track.stop());
    };
  }, [onDetected]);

  return (
    <div className="space-y-2">
      <video ref={videoRef} className="h-48 w-full rounded-lg bg-black object-cover" muted playsInline />
      {error ? <p className="text-sm text-amber-700">{error}</p> : null}
    </div>
  );
}
