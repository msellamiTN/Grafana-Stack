#!/usr/bin/env python3
"""
Payment API Simulation Script
Data2AI Academy - Training Stack

Simulates realistic payment traffic with multiple modes:
- normal: Standard traffic pattern
- burst: High-speed sequential requests
- peak: High concurrent traffic
- stress: Maximum load testing
- realistic: Variable traffic with bursts
"""

import argparse
import asyncio
import random
import time
from datetime import datetime
from typing import Dict, List, Tuple
import aiohttp
from colorama import Fore, Style, init

# Initialize colorama for cross-platform colored output
init(autoreset=True)


class PaymentSimulator:
    """Payment API traffic simulator with multiple modes"""
    
    def __init__(self, api_url: str, num_requests: int, mode: str, max_concurrent: int):
        self.api_url = api_url
        self.num_requests = num_requests
        self.mode = mode
        self.max_concurrent = max_concurrent
        
        # Statistics
        self.total_success = 0
        self.total_failed = 0
        self.total_amount = 0.0
        self.response_times = []
        
        # Currency distribution (weighted)
        self.currencies = ['USD', 'EUR', 'GBP', 'CHF', 'JPY']
        self.currency_weights = [25, 50, 15, 7, 3]  # Percentages
        
    def random_amount(self, range_type: str = 'auto') -> float:
        """Generate random payment amount based on distribution"""
        if range_type == 'small':
            return round(random.uniform(10, 200), 2)
        elif range_type == 'medium':
            return round(random.uniform(200, 1000), 2)
        elif range_type == 'large':
            return round(random.uniform(1000, 6000), 2)
        else:
            # Realistic distribution: 80% small, 15% medium, 5% large
            rand = random.random()
            if rand < 0.80:
                return round(random.uniform(10, 200), 2)
            elif rand < 0.95:
                return round(random.uniform(200, 1000), 2)
            else:
                return round(random.uniform(1000, 6000), 2)
    
    def random_currency(self) -> str:
        """Generate random currency based on weighted distribution"""
        return random.choices(self.currencies, weights=self.currency_weights)[0]
    
    def random_customer(self) -> str:
        """Generate random customer ID with realistic distribution"""
        # 20% returning customers (lower IDs), 80% various customers
        if random.random() < 0.20:
            # Returning customers
            return f"cust_{random.randint(1, 100):05d}"
        else:
            # Regular customers
            return f"cust_{random.randint(1, 5000):05d}"
    
    def random_payment_type(self) -> str:
        """Generate random payment type"""
        types = ['standard', 'express', 'recurring']
        weights = [70, 20, 10]
        return random.choices(types, weights=weights)[0]
    
    def get_delay(self) -> float:
        """Get delay between requests based on simulation mode"""
        delays = {
            'burst': 0.1,
            'peak': 0.5,
            'normal': random.uniform(1, 3),
            'realistic': random.uniform(0.5, 5),
            'stress': 0.01
        }
        return delays.get(self.mode, 1.0)
    
    async def make_payment(self, session: aiohttp.ClientSession, request_num: int) -> Dict:
        """Make a single payment request"""
        amount = self.random_amount()
        currency = self.random_currency()
        customer = self.random_customer()
        payment_type = self.random_payment_type()
        
        payload = {
            'amount': amount,
            'currency': currency,
            'customerId': customer,
            'type': payment_type
        }
        
        start_time = time.time()
        
        try:
            async with session.post(
                f"{self.api_url}/api/payments",
                json=payload,
                timeout=aiohttp.ClientTimeout(total=10)
            ) as response:
                duration = time.time() - start_time
                self.response_times.append(duration)
                
                if response.status == 200:
                    data = await response.json()
                    self.total_success += 1
                    self.total_amount += data.get('amount', amount)
                    
                    print(f"[{request_num}] {Fore.GREEN}✓{Style.RESET_ALL} "
                          f"Payment {data.get('paymentId', 'N/A')} | "
                          f"{data.get('amount', amount):.2f} {currency} | "
                          f"Customer: {customer} | {duration:.3f}s")
                    
                    return {'status': 'success', 'duration': duration}
                else:
                    self.total_failed += 1
                    print(f"[{request_num}] {Fore.RED}✗{Style.RESET_ALL} "
                          f"HTTP {response.status} | {amount:.2f} {currency} | "
                          f"Customer: {customer} | {duration:.3f}s")
                    
                    return {'status': 'failed', 'duration': duration}
                    
        except asyncio.TimeoutError:
            duration = time.time() - start_time
            self.total_failed += 1
            print(f"[{request_num}] {Fore.RED}✗{Style.RESET_ALL} "
                  f"TIMEOUT | {amount:.2f} {currency} | {duration:.3f}s")
            return {'status': 'timeout', 'duration': duration}
            
        except Exception as e:
            duration = time.time() - start_time
            self.total_failed += 1
            print(f"[{request_num}] {Fore.RED}✗{Style.RESET_ALL} "
                  f"ERROR: {str(e)[:50]} | {duration:.3f}s")
            return {'status': 'error', 'duration': duration}
    
    async def run_concurrent_batch(self, session: aiohttp.ClientSession, 
                                   start_index: int, batch_size: int) -> List[Dict]:
        """Run a batch of concurrent payment requests"""
        tasks = []
        for i in range(batch_size):
            request_num = start_index + i
            if request_num <= self.num_requests:
                tasks.append(self.make_payment(session, request_num))
        
        return await asyncio.gather(*tasks)
    
    async def check_health(self, session: aiohttp.ClientSession) -> bool:
        """Check if Payment API is healthy"""
        try:
            async with session.get(
                f"{self.api_url}/health",
                timeout=aiohttp.ClientTimeout(total=5)
            ) as response:
                return response.status == 200
        except:
            return False
    
    async def run_simulation(self):
        """Run the payment simulation based on selected mode"""
        print(f"{Fore.BLUE}{'='*50}{Style.RESET_ALL}")
        print(f"{Fore.BLUE}🚀 Payment API Simulation{Style.RESET_ALL}")
        print(f"{Fore.BLUE}{'='*50}{Style.RESET_ALL}")
        print(f"API URL:          {self.api_url}")
        print(f"Requests:         {self.num_requests}")
        print(f"Mode:             {Fore.YELLOW}{self.mode}{Style.RESET_ALL}")
        print(f"Max Concurrent:   {self.max_concurrent}")
        print(f"{Fore.BLUE}{'='*50}{Style.RESET_ALL}\n")
        
        # Create session
        async with aiohttp.ClientSession() as session:
            # Health check
            print(f"{Fore.YELLOW}🔍 Checking API health...{Style.RESET_ALL}")
            if await self.check_health(session):
                print(f"{Fore.GREEN}✓ API is healthy{Style.RESET_ALL}\n")
            else:
                print(f"{Fore.RED}✗ API is not responding. Please start the service.{Style.RESET_ALL}")
                return
            
            # Start simulation
            start_time = time.time()
            
            if self.mode == 'burst':
                print(f"{Fore.YELLOW}⚡ Running BURST mode (high-speed sequential){Style.RESET_ALL}\n")
                for i in range(1, self.num_requests + 1):
                    await self.make_payment(session, i)
                    await asyncio.sleep(self.get_delay())
            
            elif self.mode == 'peak':
                print(f"{Fore.YELLOW}📈 Running PEAK mode (high concurrent traffic){Style.RESET_ALL}\n")
                for i in range(1, self.num_requests + 1, self.max_concurrent):
                    batch_size = min(self.max_concurrent, self.num_requests - i + 1)
                    await self.run_concurrent_batch(session, i, batch_size)
                    await asyncio.sleep(self.get_delay())
            
            elif self.mode == 'stress':
                print(f"{Fore.RED}💥 Running STRESS mode (maximum load){Style.RESET_ALL}\n")
                for i in range(1, self.num_requests + 1, self.max_concurrent):
                    batch_size = min(self.max_concurrent, self.num_requests - i + 1)
                    await self.run_concurrent_batch(session, i, batch_size)
                    await asyncio.sleep(self.get_delay())
            
            elif self.mode == 'realistic':
                print(f"{Fore.YELLOW}🌍 Running REALISTIC mode (variable traffic patterns){Style.RESET_ALL}\n")
                i = 1
                while i <= self.num_requests:
                    # Simulate concurrent batches occasionally (30% chance)
                    if random.random() < 0.30 and (self.num_requests - i) >= 3:
                        print(f"{Fore.BLUE}[Concurrent batch]{Style.RESET_ALL}")
                        await self.run_concurrent_batch(session, i, 3)
                        i += 3
                    else:
                        await self.make_payment(session, i)
                        i += 1
                    await asyncio.sleep(self.get_delay())
            
            else:  # normal mode
                print(f"{Fore.YELLOW}⚙️  Running NORMAL mode (standard traffic){Style.RESET_ALL}\n")
                for i in range(1, self.num_requests + 1):
                    await self.make_payment(session, i)
                    await asyncio.sleep(self.get_delay())
            
            # Calculate statistics
            elapsed = time.time() - start_time
            self.show_stats(elapsed)
    
    def show_stats(self, elapsed: float):
        """Display simulation statistics"""
        total = self.total_success + self.total_failed
        success_rate = (self.total_success / total * 100) if total > 0 else 0
        
        print(f"\n{Fore.BLUE}{'='*50}{Style.RESET_ALL}")
        print(f"{Fore.BLUE}📊 Simulation Statistics{Style.RESET_ALL}")
        print(f"{Fore.BLUE}{'='*50}{Style.RESET_ALL}")
        print(f"Mode:             {Fore.YELLOW}{self.mode}{Style.RESET_ALL}")
        print(f"Duration:         {elapsed:.2f}s")
        print(f"Total Requests:   {total}")
        print(f"{Fore.GREEN}Successful:       {self.total_success}{Style.RESET_ALL}")
        print(f"{Fore.RED}Failed:           {self.total_failed}{Style.RESET_ALL}")
        print(f"Success Rate:     {success_rate:.2f}%")
        print(f"Total Amount:     ${self.total_amount:,.2f}")
        
        if total > 0 and elapsed > 0:
            tps = total / elapsed
            print(f"Throughput:       {tps:.2f} req/s")
        
        if self.response_times:
            avg_response = sum(self.response_times) / len(self.response_times)
            min_response = min(self.response_times)
            max_response = max(self.response_times)
            p95_response = sorted(self.response_times)[int(len(self.response_times) * 0.95)]
            
            print(f"\nResponse Times:")
            print(f"  Average:        {avg_response:.3f}s")
            print(f"  Min:            {min_response:.3f}s")
            print(f"  Max:            {max_response:.3f}s")
            print(f"  P95:            {p95_response:.3f}s")
        
        print(f"{Fore.BLUE}{'='*50}{Style.RESET_ALL}")


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description='Payment API Simulation Script',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Simulation Modes:
  normal     - Standard traffic pattern (1-3s delay)
  burst      - High-speed sequential requests (0.1s delay)
  peak       - High concurrent traffic (0.5s delay)
  stress     - Maximum load testing (0.01s delay)
  realistic  - Variable traffic with bursts (0.5-5s delay)

Examples:
  python simulate.py                           # 100 requests, normal mode
  python simulate.py -n 500 -m peak           # 500 requests, peak mode
  python simulate.py -n 1000 -m stress -c 10  # 1000 requests, stress mode, 10 concurrent
  python simulate.py -n 200 -m realistic      # 200 requests, realistic mode
        """
    )
    
    parser.add_argument(
        '-u', '--url',
        default='http://localhost:8081',
        help='Payment API URL (default: http://localhost:8081)'
    )
    
    parser.add_argument(
        '-n', '--num-requests',
        type=int,
        default=100,
        help='Number of payment requests to simulate (default: 100)'
    )
    
    parser.add_argument(
        '-m', '--mode',
        choices=['normal', 'burst', 'peak', 'stress', 'realistic'],
        default='normal',
        help='Simulation mode (default: normal)'
    )
    
    parser.add_argument(
        '-c', '--max-concurrent',
        type=int,
        default=5,
        help='Maximum concurrent requests (default: 5)'
    )
    
    args = parser.parse_args()
    
    # Create and run simulator
    simulator = PaymentSimulator(
        api_url=args.url,
        num_requests=args.num_requests,
        mode=args.mode,
        max_concurrent=args.max_concurrent
    )
    
    try:
        asyncio.run(simulator.run_simulation())
        print(f"\n{Fore.GREEN}✅ Simulation completed!{Style.RESET_ALL}\n")
    except KeyboardInterrupt:
        print(f"\n{Fore.YELLOW}⚠️  Simulation interrupted by user{Style.RESET_ALL}\n")
    except Exception as e:
        print(f"\n{Fore.RED}❌ Error: {str(e)}{Style.RESET_ALL}\n")


if __name__ == '__main__':
    main()
